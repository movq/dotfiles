(use-modules (gnu)
             (gnu system setuid)
             (guix channels)
             (guix inferior)
             (movq packages linux)
             (nongnu packages linux)
             (srfi srfi-1))

(use-service-modules dbus desktop networking security-token ssh sysctl xorg)
(use-package-modules certs gnome linux package-management security-token ssh firmware)

(define kernel-channels
  (list (channel
         (name 'guix)
         (url "https://github.com/movq/guix.git")
         (commit "d51b264b542936c7e82ee0d93f05ad8df23d2fd2"))
        (channel
         (name 'nonguix)
         (url "https://github.com/movq/nonguix.git")
         (commit "f41f0c04113b270162501e24bd79e3641d48324b"))
        (channel
         (name 'movq-guix)
         (url "https://git.sr.ht/~movq/movq-guix")
         (commit "c243b27dff073a373e33a01666b3a8970529d9d6"))))

(define kernel-inferior
  (inferior-for-channels kernel-channels))

(operating-system
  ;(kernel (first (lookup-inferior-packages kernel-inferior "linux-movq-xps13")))
  (kernel linux-movq-xps13)
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

  (packages (append (list nss-certs) %base-packages))

  (services 
   (let ((my-services (modify-services %base-services
                        (guix-service-type config =>
                                           (guix-configuration
                                            (inherit config)
                                            (substitute-urls
                                             (list "https://ci.vala.xyz"
                                                   "https://bordeaux.guix.gnu.org"
                                                   "https://ci.guix.gnu.org"
                                                   ))
                                            (authorized-keys
                                             (list
                                               (plain-file "berlin.pub" "(public-key(ecc(curve Ed25519)(q #8D156F295D24B0D9A86FA5741A840FF2D24F60F7B6C4134814AD55625971B394#)))")
                                               (plain-file "bordeaux.pub" "(public-key(ecc(curve Ed25519)(q #7D602902D3A2DBB83F8A0FB98602A754C5493B0B778C8D1DD4E0F41DE14DE34F#)))")
                                               (plain-file "movq.pub" "(public-key(ecc(curve Ed25519)(q #39B5DF8F64652327ABB31D8939A186CA63FA707A881BD18253D85FE9345ED896#)))")))))
                        (sysctl-service-type config =>
                                             (sysctl-configuration
                                               (settings (append '(("kernel.sysrq" . "1")
                                                                   ("kernel.dmesg_restrict" . "0"))
                                                                 %default-sysctl-settings)))))))
     (append (list
              ;(service gnome-desktop-service-type)
              ;(set-xorg-configuration
              ;  (xorg-configuration
              ;    (keyboard-layout keyboard-layout)))

              polkit-wheel-service
              fontconfig-file-system-service
              (service network-manager-service-type)
              (service wpa-supplicant-service-type)
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
                                (handle-lid-switch-external-power 'suspend)
                                (kill-user-processes? #t)))
              (dbus-service)

              x11-socket-directory-service

              (service pcscd-service-type)
              (bluetooth-service #:auto-enable? #t)
              (udev-rules-service 'u2f libu2f-host #:groups '("plugdev"))

              ;; useless until core-updates is merged :(
              (simple-service 'swaylock-pam pam-root-service-type
                (list (unix-pam-service "swaylock"))))
             ;(service gdm-service-type)
               ;(simple-service 'network-manager-applet
                ;               profile-service-type
                 ;              (list network-manager-applet))
               ;(accountsservice-service)
             my-services))))
