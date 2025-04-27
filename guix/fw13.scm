(use-modules (gnu)
             (gnu system accounts)
             (gnu system privilege)
             (gnu system setuid)
             (gnu system shadow)
             (guix channels)
             (guix inferior)
             (gnu packages admin)
             (gnu packages android)
             (gnu packages bash)
             (movq packages linux)
             (nongnu packages linux)
             (srfi srfi-1))

(use-service-modules dbus desktop networking security-token shepherd ssh sysctl xorg)
(use-package-modules certs gnome linux package-management security-token ssh firmware)

(operating-system
  ;(kernel (first (lookup-inferior-packages kernel-inferior "linux-movq-xps13")))
  (kernel linux-movq-fw13)
  (kernel-arguments (append (list "mitigations=off" "amdgpu.dcdebugmask=0x10" "resume=/dev/mapper/nvme0n1p2-crypt" "resume_offset=13378816")
                            %default-kernel-arguments))
  (initrd-modules (list "nvme" "aesni-intel" "dm-crypt" "crc32c-generic" "crc32c-intel" "btrfs"))
  (firmware (list linux-firmware))
  (host-name "mike-framework")
  (timezone "Europe/London")
  (locale "en_GB.utf8")
  (locale-libcs (list glibc))
  (keyboard-layout (keyboard-layout "gb" "dvorak" #:options (list "ctrl:swapcaps")))

  (bootloader (bootloader-configuration
               (bootloader grub-efi-bootloader)
               (targets '("/efi"))
               (keyboard-layout keyboard-layout)))

  (mapped-devices
   (list
    (mapped-device
     (source (uuid "00814310-5bec-41f7-a265-fe6b9e3690d8"))
     (target "nvme0n1p2-crypt")
     (type luks-device-mapping))))

  (file-systems (append
                 (list (file-system
                         (device (uuid "2ccc0c18-b649-49ae-bc5c-618de8bbb3d5"))
                         (mount-point "/")
                         (type "btrfs")
                         (flags '(no-atime))
                         (options "subvol=/guix,compress-force=zstd:3,nodiscard")
                         (dependencies mapped-devices))
                       (file-system
                         (device (uuid "2ccc0c18-b649-49ae-bc5c-618de8bbb3d5"))
                         (mount-point "/home")
                         (type "btrfs")
                         (flags '(no-atime))
                         (options "subvol=/home,compress-force=zstd:3,nodiscard")
                         (dependencies mapped-devices))
                       (file-system
                         (device (uuid "2ccc0c18-b649-49ae-bc5c-618de8bbb3d5"))
                         (mount-point "/mnt/rootvol")
                         (type "btrfs")
                         (flags '(no-atime))
                         (options "subvol=/,compress-force=zstd:3,nodiscard")
                         (dependencies mapped-devices))
                       (file-system
                         (device (uuid "454A-A115" 'fat))
                         (mount-point "/efi")
                         (type "vfat"))
                       (file-system
                         (device "none")
                         (mount-point "/run/user")
                         (type "tmpfs")
                         (check? #f)
                         (flags '(no-suid no-dev no-exec))
                         (options "mode=0755")
                         (create-mount-point? #t))
                       (file-system
                         (device "none")
                         (mount-point "/home/mike/.cache/thumbnails")
                         (type "tmpfs")
                         (check? #f)
                         (options "uid=1000,gid=1000,mode=0755")))
                 %base-file-systems))
  (swap-devices
  (list
    (swap-space
      (target "/mnt/rootvol/swap/swapfile")
      (dependencies (filter (file-system-mount-point-predicate "/mnt/rootvol")
                            file-systems)))))

  (groups
    (append
      (list (user-group
              (name "mike")
              (id 1000))
            (user-group
              (name "nixbld")
              (system? #t)))
      %base-groups))

  (users
    (append
      (list (user-account
              (name "mike")
              (uid 1000)
              (comment "")
              (group "mike")
              (supplementary-groups '("wheel" "audio" "video" "input" "lp" "plugdev" "seat" "adbusers")))
            (user-account
              (name "nixbuilder")
              (home-directory "/var/empty")
              (shell (file-append shadow "/sbin/nologin"))
              (group "nixbld")
              (supplementary-groups '("nixbld"))
              (system? #t)))
      %base-user-accounts))

  (sudoers-file (plain-file "sudoers" "root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL"))

  (packages (append %base-packages
                    (list opendoas)))

  (services 
   (let ((my-services (modify-services %base-services
                        (guix-service-type config =>
                                           (guix-configuration
                                            (inherit config)
                                            (substitute-urls
                                             (list "http://sv1.movq.org:8080"
                                                   "https://bordeaux.guix.gnu.org"
                                                   "https://ci.guix.gnu.org"
                                                   ))
                                            (authorize-key? #t)
                                            (authorized-keys
                                             (list
                                               (plain-file "berlin.pub" "(public-key(ecc(curve Ed25519)(q #8D156F295D24B0D9A86FA5741A840FF2D24F60F7B6C4134814AD55625971B394#)))")
                                               (plain-file "bordeaux.pub" "(public-key(ecc(curve Ed25519)(q #7D602902D3A2DBB83F8A0FB98602A754C5493B0B778C8D1DD4E0F41DE14DE34F#)))")
                                               (plain-file "alienware.pub" "(public-key(ecc(curve Ed25519)(q #C1C11891A5AC0C66DF15B76DEA19A37168B3963AD5246D9830B6A45095EF2C9B#)))")
                                               (plain-file "sv1.pub" "(public-key(ecc(curve Ed25519)(q #C764270F086A95B3A873BAE629797C37D64F068A0EBA1C036C3A8E6841C5AB4B#)))")))
                                            (extra-options '("--gc-keep-derivations=yes" "--gc-keep-outputs=yes"))))
                        (sysctl-service-type config =>
                                             (sysctl-configuration
                                               (settings (append '(("kernel.sysrq" . "1")
                                                                   ("kernel.dmesg_restrict" . "0"))
                                                                 %default-sysctl-settings))))
                        (shepherd-system-log-service-type config =>
                                             (system-log-configuration
                                               (inherit config)
                                               (message-destination
                                                 #~(lambda _
                                                     '())))))))
     (append (list
              (extra-special-file "/etc/alsa/conf.d/50-pipewire.conf"
                (file-append pipewire "/share/alsa/alsa.conf.d/50-pipewire.conf"))
              (extra-special-file "/etc/alsa/conf.d/99-pipewire-default.conf"
                (file-append pipewire "/share/alsa/alsa.conf.d/99-pipewire-default.conf"))

              polkit-wheel-service
              fontconfig-file-system-service
              (service network-manager-service-type)
              (service wpa-supplicant-service-type)
              (service openssh-service-type
                       (openssh-configuration
                        (openssh openssh-sans-x)))

              (service polkit-service-type)
              (simple-service 'polkit-wheel-all polkit-service-type
                (list (file-union "polkit-wheel-all"
                                  `(("share/polkit-1/rules.d/00-wheel-all.rules"
                                     ,(plain-file "00-wheel-all.rules"
"polkit.addRule(function(action, subject) {
    if (subject.isInGroup(\"wheel\")) {
        return polkit.Result.YES;
    }
});
"))))))
              (simple-service 'doas-config etc-service-type
                (list `("doas.conf" ,(plain-file "doas.conf" "permit nopass keepenv nolog :wheel\n"))))
              (service seatd-service-type)
              (service dbus-root-service-type)

              (service x11-socket-directory-service-type)

              (service pcscd-service-type)
              (service bluetooth-service-type
                (bluetooth-configuration (auto-enable? #t)))
              (udev-rules-service 'u2f libu2f-host #:groups '("plugdev"))
              (udev-rules-service 'brightness brightnessctl)
              (udev-rules-service 'android android-udev-rules #:groups '("adbusers"))

             (service subids-service-type
               (subids-configuration
                (add-root? #f)))
             (simple-service 'mike-subids
                subids-service-type
                (subids-extension
                  (subgids
                   (list
                    (subid-range (name "mike"))))
                  (subuids
                   (list
                    (subid-range (name "mike")))))))
             my-services)))
  (privileged-programs
    (append (list (privileged-program
                    (program (file-append opendoas "/bin/doas"))
                    (setuid? #t)))
            %default-privileged-programs)))
