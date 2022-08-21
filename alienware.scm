(use-modules (gnu)
             (guix channels)
             (guix inferior)
             (guix transformations)
             (movq packages linux)
             (movq packages nvidia)
             (movq system mapped-devices)
             (nongnu packages linux)
             (srfi srfi-1))

(use-service-modules dbus desktop networking security-token ssh xorg)
(use-package-modules certs package-management security-token ssh xorg)

(define evil
  (options->transformation
    '((with-graft . "mesa=nvda"))))

(define xorg-server/evil
  (evil xorg-server))

; Following two functions copied from GNU Guix.
; License: GPLv3
(define* (xorg-wrapper #:optional (config (xorg-configuration)))
  "Return a derivation that builds a script to start the X server with the
given @var{config}.  The resulting script should be used in place of
@code{/usr/bin/X}."
  (define exp
    ;; Write a small wrapper around the X server.
    #~(begin
        (setenv "XORG_DRI_DRIVER_PATH" (string-append #$nvda "/lib/dri"))
        (setenv "XKB_BINDIR" (string-append #$xkbcomp "/bin"))

        (let ((X (string-append #$(xorg-configuration-server config) "/bin/X"))
          (xinit (string-append #$(evil xinit) "/bin/xinit")))
          (apply execl xinit xinit
                 "--" X
                 "-xkbdir" (string-append #$xkeyboard-config "/share/X11/xkb")
                 "-config" #$((@@ (gnu services xorg) xorg-configuration->file) config)
                 "-configdir" #$((@@ (gnu services xorg) xorg-configuration-directory)
                                 (xorg-configuration-modules config))
                 (cdr (command-line))))))

  (program-file "X-wrapper" exp))

(define* (xorg-start-command #:optional (config (xorg-configuration)))
  "Return a @code{startx} script in which the modules, fonts, etc. specified
in @var{config}, are available.  The result should be used in place of
@code{startx}."
  (define X
    (xorg-wrapper config))
  (define exp
    ;; Write a small wrapper around the X server.
    #~(apply execl #$X #$X ;; Second #$X is for argv[0].
             "-logverbose" "-verbose" "-terminate"
             #$@(xorg-configuration-server-arguments config)
              (cdr (command-line))))

  (program-file "startx" exp))

(operating-system
  (kernel linux)
  (kernel-arguments
    (append %default-kernel-arguments 
            (list "modprobe.blacklist=nouveau"
                  "nomodeset"
                  "loglevel=3")))
  (firmware (list linux-firmware))
  (kernel-loadable-modules (list nvidia-driver))
  (host-name "mike-alienware")
  (timezone "Europe/London")
  (locale "en_GB.utf8")
  (keyboard-layout (keyboard-layout "us" "dvorak" #:options (list "ctrl:swapcaps")))

  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets '("/efi"))
                (keyboard-layout keyboard-layout)))

  (mapped-devices
    (list
      (mapped-device
        (source (uuid "474fb1d5-dac8-433a-af30-bde6468e791d"))
        (target "luks-474fb1d5-dac8-433a-af30-bde6468e791d")
        (type luks-device-mapping-discard))))

  (file-systems (append
                  (list (file-system
                          (device (uuid "5c1caf3a-152a-41ee-aac7-8d03a923ffee"))
                          (mount-point "/")
                          (type "btrfs")
                          (options "subvol=/guix,compress-force=zstd:3")
                          (dependencies mapped-devices))
                        (file-system
                          (device (uuid "5c1caf3a-152a-41ee-aac7-8d03a923ffee"))
                          (mount-point "/home")
                          (type "btrfs")
                          (options "subvol=/home,compress-force=zstd:3")
                          (dependencies mapped-devices))
                        (file-system
                          (device (uuid "AB1A-6FE4" 'fat))
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
                 (supplementary-groups '("wheel" "audio" "video" "input" "lp")))
               %base-user-accounts))

  (sudoers-file (plain-file "sudoers" "root ALL=(ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL"))

  (packages (append (list nvidia-driver
              nss-certs)
            %base-packages))

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
                (udev-rules-service 'u2f libu2f-host #:groups '("plugdev"))
                (udev-rules-service 'nvidia nvidia-driver)
                (accountsservice-service)
        (extra-special-file
          "/usr/bin/startx"
          (xorg-start-command
                      (xorg-configuration
                             (modules (list xf86-input-libinput nvidia-driver))
                             (drivers (list "nvidia"))
                 (server (evil xorg-server))
                 (keyboard-layout keyboard-layout)
                 (extra-config (list
"
Section \"InputClass\"
    Identifier \"touchpad\"
    Driver \"libinput\"
    MatchIsTouchpad \"on\"
    Option \"Tapping\" \"on\"
EndSection
"))))))
                my-services))))
