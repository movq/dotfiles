(use-modules (gnu)
             (gnu system setuid)
             (guix channels)
             (guix inferior)
             (movq packages linux)
             (movq system mapped-devices)
             (nongnu packages linux)
             (srfi srfi-1))

(use-service-modules dbus desktop networking security-token ssh)
(use-package-modules certs package-management security-token ssh)

(define kernel-channels
  (list (channel
         (name 'guix)
         (url "https://github.com/movq/guix.git")
         (commit "50fd5987298b9deb507f5beba7c6dcf396e58673")
         (introduction
          (make-channel-introduction
           "9edb3f66fd807b096b48283debdcddccfea34bad"
           (openpgp-fingerprint
            "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
        (channel
         (name 'nonguix)
         (url "https://github.com/movq/nonguix.git")
         (commit "bba908b38dee4458079b2574ef968a347bbe30e9"))
        (channel
         (name 'movq-guix)
         (url "https://git.sr.ht/~movq/movq-guix")
         (commit "f876ea646b34728805dd4bfca4ca4780a2da3023")
         (introduction
          (make-channel-introduction
           "85a5f800bacd22f899816fe976b613fbba43ad24"
           (openpgp-fingerprint
            "4914197BEB999068EF4FE6003653478810E355A4"))))))

(define kernel-inferior
  (inferior-for-channels kernel-channels))

(operating-system
  (kernel (first (lookup-inferior-packages kernel-inferior "linux-movq-xps13")))
  (kernel-arguments (append (list "mem_sleep_default=deep"
                                  "pci=noaer"
                                  "mitigations=off")
                            %default-kernel-arguments))
  (initrd-modules (list "nvme" "dm-crypt"))
  (firmware (list atheros-firmware i915-firmware))
  (host-name "mike-xps")
  (timezone "Europe/London")
  (locale "en_GB.utf8")
  (keyboard-layout (keyboard-layout "gb" "dvorak" #:options (list "ctrl:swapcaps")))

  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)
               (targets '("/efi"))
               (keyboard-layout keyboard-layout)))

  (mapped-devices
   (list
    (mapped-device
     (source "linux-vg")
     (target "linux--vg-rootvol")
     (type lvm-device-mapping))
    (mapped-device
     (source (uuid "ef303222-1ac9-4116-9c1f-bc334957a797"))
     (target "luks-ef303222-1ac9-4116-9c1f-bc334957a797")
     (type luks-device-mapping-discard))))

  (file-systems (append
                 (list (file-system
                         (device (uuid "6b7e36da-d23b-4d33-8b95-77b8b877d0ef"))
                         (mount-point "/")
                         (type "btrfs")
                         (options "subvol=/guix,compress-force=zstd:3")
                         (dependencies mapped-devices))
                       (file-system
                         (device (uuid "6b7e36da-d23b-4d33-8b95-77b8b877d0ef"))
                         (mount-point "/home")
                         (type "btrfs")
                         (options "subvol=/home,compress-force=zstd:3")
                         (dependencies mapped-devices))
                       (file-system
                         (device (uuid "956A-FD27" 'fat))
                         (mount-point "/efi")
                         (type "vfat")))
                 %base-file-systems))

  (groups (cons (user-group
                 (name "mike")
                 (id 1000))
                %base-groups))

  (users (cons (user-account
                (name "mike")
                (uid 1000)
                (comment "")
                (group "mike")
                (supplementary-groups '("wheel" "audio" "video" "lp")))
               %base-user-accounts))

  (sudoers-file (plain-file "sudoers" "root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL"))

  (packages (append (list nss-certs) %base-packages))


  (services 
   (let ((my-services (modify-services %base-services
                        (guix-service-type config =>
                                           (guix-configuration
                                            (inherit config)
                                            (substitute-urls
                                             (list "https://ci.guix.gnu.org"
                                                   "https://bordeaux.guix.gnu.org"
                                                   "https://substitutes.nonguix.org"))
                                            (authorized-keys
                                             (list (file-append guix "/share/guix/berlin.guix.gnu.org.pub")
                                                   (file-append guix "/share/guix/bordeaux.guix.gnu.org.pub")
                                                   (plain-file "inspiron.pub" "(public-key(ecc(curve Ed25519)(q #3D538437832F3FFC9A9B44E928021978B0C2D1A16F4C1272284FB2851BA80F5F#)))")
                                                   (plain-file "nonguix.pub" "(public-key(ecc(curve Ed25519)(q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))))))))
     (append (list
                                        ;(service gdm-service-type
                                        ;  (gdm-configuration))
              polkit-wheel-service
              fontconfig-file-system-service
              (service network-manager-service-type)
              (service wpa-supplicant-service-type)
                                        ;(simple-service 'network-manager-applet
                                        ;         profile-service-type
                                        ;         (list network-manager-applet))

              (service openssh-service-type
                       (openssh-configuration
                        (openssh openssh-sans-x)))

              (udisks-service)
              (service upower-service-type)
              (accountsservice-service)
              (service colord-service-type)
              (geoclue-service)
              (service polkit-service-type)
              (elogind-service #:config
                               (elogind-configuration
                                (handle-lid-switch-external-power 'suspend)))
              (dbus-service)

              x11-socket-directory-service

              (service pcscd-service-type)
              (bluetooth-service #:auto-enable? #t)
              (udev-rules-service 'u2f libu2f-host #:groups '("plugdev"))

              )
             my-services))))
