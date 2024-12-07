(use-modules (gnu)
             (gnu system setuid)
             (guix channels)
             (guix inferior)
             (movq packages linux)
             (movq packages rtkit)
             (nongnu packages linux)
             (srfi srfi-1))

(use-service-modules dbus desktop networking security-token shepherd ssh sysctl xorg)
(use-package-modules certs gnome linux package-management security-token ssh firmware)

(define %my-elogind-file-systems
  ;; We don't use systemd, but these file systems are needed for elogind,
  ;; which was extracted from systemd.
  (append
   (list (file-system
           (device "none")
           (mount-point "/run/systemd")
           (type "tmpfs")
           (check? #f)
           (flags '(no-suid no-dev no-exec))
           (options "mode=0755")
           (create-mount-point? #t))
         (file-system
           (device "none")
           (mount-point "/run/user")
           (type "tmpfs")
           (check? #f)
           (flags '(no-suid no-dev no-exec))
           (options "mode=0755")
           (create-mount-point? #t))
         ;; Elogind uses cgroups to organize processes, allowing it to map PIDs
         ;; to sessions.  Elogind's cgroup hierarchy isn't associated with any
         ;; resource controller ("subsystem").
         (file-system
           (device "none")
           (mount-point "/sys/fs/cgroup")
           (type "cgroup2")
           (check? #f)
           (create-mount-point? #t)))))

(define my-elogind-service-type
  (service-type (name 'elogind)
                (extensions
                 (list (service-extension dbus-root-service-type
                                          (@@ (gnu services desktop) elogind-dbus-service))
                       (service-extension udev-service-type
                                          (compose list (@@ (gnu services desktop) elogind-package)))
                       (service-extension polkit-service-type
                                          (compose list (@@ (gnu services desktop) elogind-package)))

                       ;; Start elogind from the Shepherd rather than waiting
                       ;; for bus activation.  This ensures that it can handle
                       ;; events like lid close, etc.
                       (service-extension shepherd-root-service-type
                                          (@@ (gnu services desktop) elogind-shepherd-service))

                       ;; Provide the 'loginctl' command.
                       (service-extension profile-service-type
                                          (compose list (@@ (gnu services desktop) elogind-package)))

                       ;; Extend PAM with pam_elogind.so.
                       (service-extension pam-root-service-type
                                          (@@ (gnu services desktop) pam-extension-procedure))

                       ;; We need /run/user, /run/systemd, etc.
                       (service-extension file-system-service-type
                                          (const %my-elogind-file-systems))))
                (default-value (elogind-configuration))
                (description "Run the @command{elogind} login and seat
management service.  The @command{elogind} service integrates with PAM to
allow other system components to know the set of logged-in users as well as
their session types (graphical, console, remote, etc.).  It can also clean up
after users when they log out.")))

(define* (my-elogind-service #:key (config (elogind-configuration)))
  "Return a service that runs the @command{elogind} login and seat management
service.  The @command{elogind} service integrates with PAM to allow other
system components to know the set of logged-in users as well as their session
types (graphical, console, remote, etc.).  It can also clean up after users
when they log out."
  (service my-elogind-service-type config))


(operating-system
  ;(kernel (first (lookup-inferior-packages kernel-inferior "linux-movq-xps13")))
  (kernel linux-movq-xps13)
  ;(kernel linux-6.5)
  (kernel-arguments (append (list "mitigations=off")
                            %default-kernel-arguments))
  (initrd-modules (list "dm-crypt" "btrfs" "xts" "aesni-intel"))
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
     (source (uuid "68f7ff60-1018-4951-99e2-cf8564736ee3"))
     (target "luks-68f7ff60-1018-4951-99e2-cf8564736ee3")
     (type luks-device-mapping))))

  (file-systems (append
                 (list (file-system
                         (device (uuid "6a431a8f-d7fe-4aac-b242-311ca636b259"))
                         (mount-point "/")
                         (type "btrfs")
                         (options "subvol=/guix,compress-force=zstd:3,nodiscard")
                         (dependencies mapped-devices))
                       (file-system
                         (device (uuid "6a431a8f-d7fe-4aac-b242-311ca636b259"))
                         (mount-point "/home")
                         (type "btrfs")
                         (options "subvol=/home,compress-force=zstd:3,nodiscard")
                         (dependencies mapped-devices))
                       (file-system
                         (device (uuid "D778-6931" 'fat))
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
                (supplementary-groups '("wheel" "audio" "video" "lp" "plugdev")))
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
                                                   ))
                                            (authorize-key? #t)
                                            (authorized-keys
                                             (list
                                               (plain-file "movq.pub" "(public-key(ecc(curve Ed25519)(q #2CFCA1F7A98DCADB056726641204F1180CB1F950CC245B3FD411D0EF4597DF3A#)))")
                                               (plain-file "berlin.pub" "(public-key(ecc(curve Ed25519)(q #8D156F295D24B0D9A86FA5741A840FF2D24F60F7B6C4134814AD55625971B394#)))")
                                               (plain-file "bordeaux.pub" "(public-key(ecc(curve Ed25519)(q #7D602902D3A2DBB83F8A0FB98602A754C5493B0B778C8D1DD4E0F41DE14DE34F#)))")))))
                        (sysctl-service-type config =>
                                             (sysctl-configuration
                                               (settings (append '(("kernel.sysrq" . "1")
                                                                   ("kernel.dmesg_restrict" . "0"))
                                                                 %default-sysctl-settings)))))))
     (append (list
              polkit-wheel-service
              fontconfig-file-system-service
              (service network-manager-service-type)
              (service wpa-supplicant-service-type)
              (service openssh-service-type
                       (openssh-configuration
                        (openssh openssh-sans-x)))

              (udisks-service)
              (service polkit-service-type)

              (simple-service 'rtkit-polkit polkit-service-type
                (list rtkit))

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
              (my-elogind-service #:config
                               (elogind-configuration
                                 (handle-lid-switch-external-power 'suspend)
                                 (kill-user-processes? #t)))

              (dbus-service)

              (simple-service 'rtkit-dbus dbus-root-service-type
                (list rtkit))

              x11-socket-directory-service

              (service pcscd-service-type)
              (bluetooth-service #:auto-enable? #t)
              (udev-rules-service 'u2f libu2f-host #:groups '("plugdev"))
              (udev-rules-service 'brightness brightnessctl #:groups '("video"))

              ;; useless until core-updates is merged :(
              (simple-service 'swaylock-pam pam-root-service-type
                (list (unix-pam-service "swaylock")))

             (extra-special-file "/usr/share/icons/Adwaita"
                                 (file-append adwaita-icon-theme "/icons")))
             my-services))))
