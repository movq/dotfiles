(use-modules (gnu))
(use-modules (nongnu packages linux))

(use-service-modules dbus desktop networking security-token ssh)
(use-package-modules certs ssh)

(operating-system
  (kernel linux-movq-xps13)
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

  (services (append (list fontconfig-file-system-service
                          (service network-manager-service-type)
                          (service wpa-supplicant-service-type)
                          (service openssh-service-type
                                   (openssh-configuration
                                    (openssh openssh-sans-x)
                                    (port-number 2222)))
                          (udisks-service)
                          (service polkit-service-type)
                          (elogind-service)
                          (dbus-service)
                          (service pcscd-service-type)
                          (bluetooth-service #:auto-enable? #t)
                          )
                    %base-services)))
