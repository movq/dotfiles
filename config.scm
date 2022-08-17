(use-modules (gnu)
             (guix channels)
             (guix inferior)
             (nongnu packages linux)
             (srfi srfi-1))

(use-service-modules dbus desktop networking security-token ssh)
(use-package-modules certs package-management security-token ssh)

(define kernel-channels
  (list (channel
          (name 'guix)
          (url "https://github.com/movq/guix.git")
          (commit "9b5e340c1d6c8b5e7da2657e1888dbf841cdba40"))
        (channel
          (name 'nonguix)
          (url "https://github.com/movq/nonguix.git")
          (commit "3a813fb42842062bd2c598bc951dabba58bb7e90"))))

(define kernel-inferior
  (inferior-for-channels kernel-channels))

(operating-system
  (kernel (first (lookup-inferior-packages kernel-inferior "linux-movq-xps13")))
  (initrd-modules (list "nvme" "dm-crypt"))
  (firmware (append (list atheros-firmware i915-firmware)
                    %base-firmware))
  (host-name "mike-xps")
  (timezone "Europe/London")
  (locale "en_GB.utf8")
  (keyboard-layout (keyboard-layout "gb" "dvorak"))

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
        (type luks-device-mapping))))

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

  (packages (cons nss-certs %base-packages))


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
                fontconfig-file-system-service
                (service network-manager-service-type)
                (service wpa-supplicant-service-type)
                (service openssh-service-type
                         (openssh-configuration
                         (openssh openssh-sans-x)))
                (udisks-service)
                (service polkit-service-type)
                (elogind-service #:config
                                 (elogind-configuration
                                   (handle-lid-switch-external-power 'suspend)))
                (dbus-service)
                (service pcscd-service-type)
                (bluetooth-service #:auto-enable? #t)
                (udev-rules-service 'u2f libu2f-host #:groups '("plugdev")))
                my-services))))
