(use-modules (gnu)
             (gnu system accounts)
             (gnu system privilege)
             (gnu system setuid)
             (gnu system shadow)
             (guix channels)
             (guix inferior)
             (guix records)
             (gnu packages admin)
             (gnu packages android)
             (gnu packages bash)
             ((nongnu packages linux) #:prefix nongnu:)
             (ice-9 match)
             (srfi srfi-1))

(use-service-modules dbus desktop networking security-token shepherd ssh sysctl xorg)
(use-package-modules
  certs
  compression
  gawk
  gnome
  guile
  guile-xyz
  linux
  less
  man
  nss
  package-management
  pciutils
  security-token
  ssh
  vim)

(define network-manager-no-polkit-service-type
  (let ((config->packages
         (lambda (config)
           (match-record config (@@ (gnu services networking)
                                    <network-manager-configuration>)
             (network-manager vpn-plugins)
             `(,network-manager ,@vpn-plugins)))))
    (service-type
     (name 'network-manager)
     (extensions
      (list (service-extension shepherd-root-service-type
                               (@@ (gnu services networking)
                                   network-manager-shepherd-service))
            (service-extension dbus-root-service-type config->packages)
            (service-extension account-service-type
                               (@@ (gnu services networking)
                                   network-manager-accounts))
            (service-extension activation-service-type
                               (@@ (gnu services networking)
                                   network-manager-activation))
            (service-extension session-environment-service-type
                               (@@ (gnu services networking)
                                   network-manager-environment))
            (service-extension profile-service-type config->packages)))
     (default-value (network-manager-configuration))
     (description "Run NetworkManager without adding its polkit extension."))))

(define pcscd-service-type
  (service-type
   (name 'pcscd)
   (description
    "Run @command{pcscd}, the PC/SC smart card daemon.")
   (extensions
    (list (service-extension shepherd-root-service-type
                             (compose list (@@ (gnu services security-token)
                                               pcscd-shepherd-service)))
          (service-extension activation-service-type
                             (@@ (gnu services security-token)
                                 pcscd-activation))))
   (default-value (pcscd-configuration))))

(define seatd-logfile (@@ (gnu services desktop) seatd-logfile))
(define seatd-socket (@@ (gnu services desktop) seatd-socket))
(define seatd-loglevel (@@ (gnu services desktop) seatd-loglevel))
(define seatd-group (@@ (gnu services desktop) seatd-group))
(define seatd-package (@@ (gnu services desktop) seatd-package))
(define (seatd-without-elogind-shepherd-service config)
  (list (shepherd-service
         (documentation "Minimal seat management daemon")
         (requirement '(user-processes))
         (provision '(seatd))
         (start #~(make-forkexec-constructor
                   (list #$(file-append (seatd-package config) "/bin/seatd")
                         "-g" #$(user-group-name (seatd-group config)))
                   #:environment-variables
                   (list (string-append "SEATD_LOGLEVEL="
                                        #$(seatd-loglevel config))
                         (string-append "SEATD_DEFAULTPATH="
                                        #$(seatd-socket config)))
                   #:log-file #$(seatd-logfile config)))
         (stop #~(make-kill-destructor)))))

(define seatd-without-elogind-service-type
  (service-type
   (name 'seatd)
   (description "Seat management takes care of mediating access
to shared devices (graphics, input), without requiring the
applications needing access to be root.")
   (extensions
    (list
     (service-extension account-service-type (@@ (gnu services desktop) seatd-accounts))
     (service-extension session-environment-service-type (@@ (gnu services desktop) seatd-environment))
     (service-extension file-system-service-type (const %control-groups))
     (service-extension shepherd-root-service-type seatd-without-elogind-shepherd-service)))
   (default-value (seatd-configuration))))


;; --------------------------------------------------------------------
(operating-system
  (kernel linux-7.0)
  (kernel-arguments (append (list "mitigations=off" "amdgpu.dcdebugmask=0x10"
                                  "resume=/dev/mapper/nvme0n1p2-crypt" "resume_offset=13378816")
                            %default-kernel-arguments))
  (initrd-modules (list "nvme" "aesni-intel" "dm-crypt" "btrfs"))
  (firmware (list nongnu:amdgpu-firmware nongnu:mediatek-firmware))
  (host-name "mike-framework")
  (timezone "Europe/London")
  (locale "C.UTF-8")
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

  (file-systems
    (append
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
              (mount-point "/boot/efi")
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

  #;
  (sudoers-file (plain-file "sudoers" "root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL"))

  (packages
    (list
      less
      vim
      man-db
      kbd
      guile-readline
      guile-colorized
      pciutils
      usbutils
      util-linux+udev
      kmod
      eudev
      ; Networking
      nss-certs
      iproute
      iw

      ; Utils
      procps
      psmisc
      which
      shadow
      e2fsprogs
      guile-3.0-latest
      bash
      coreutils
      findutils
      grep
      sed
      diffutils
      patch
      gawk
      tar
      gzip
      bzip2
      lzip
      xz
      zstd

      opendoas))

  (services
   (let ((my-services (modify-services %base-services
                        (delete console-font-service-type)
                        (guix-service-type config =>
                                           (guix-configuration
                                            (inherit config)
                                            (substitute-urls
                                             (list "https://guix.mjones.io"))
                                            (authorize-key? #t)
                                            (authorized-keys
                                             (list
                                               (plain-file "mike.pub"
                                                           "(public-key(ecc(curve Ed25519)(q #0B12B338EF397DCBC1F7C32DF5181C018FD9208312D001E9DD00E2F0D0A08A82# )))")))
                                            (extra-options '("--gc-keep-derivations=no" "--gc-keep-outputs=no"))))
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

              fontconfig-file-system-service
              (service network-manager-no-polkit-service-type)
              (service wpa-supplicant-service-type)
              (service openssh-service-type
                       (openssh-configuration
                        (openssh openssh-sans-x)))

              (simple-service 'doas-config etc-service-type
                (list `("doas.conf" ,(plain-file "doas.conf" "permit nopass keepenv nolog :wheel\n"))))
              (service seatd-without-elogind-service-type)
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
