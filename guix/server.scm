(use-modules (gnu)
             (gnu packages linux)
             (gnu system setuid)
             (guix channels)
             (guix inferior)
             (nongnu packages linux)
             (srfi srfi-1))

(use-service-modules avahi databases dbus desktop networking ssh)
(use-package-modules certs databases package-management ssh)

(operating-system
  (kernel linux)
  (kernel-arguments (append (list "mitigations=off"
                                  "net.ifnames=0")
                            %default-kernel-arguments))
  (firmware '())
  (host-name "ulmo")
  (timezone "Europe/London")
  (locale "en_GB.utf8")

  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets '("/dev/nvme0n1"))))

  (file-systems (append
                  (list (file-system
                          (device (uuid "cd384146-5fe0-4e0b-b5e6-04195ecec2c4"))
                          (mount-point "/")
                          (type "btrfs")
                          (options "subvol=/guix"))
                        (file-system
                          (device (uuid "cd384146-5fe0-4e0b-b5e6-04195ecec2c4"))
                          (mount-point "/home")
                          (type "btrfs")
                          (options "subvol=/home"))
                        (file-system
                          (device (uuid "5da45336-4c7c-400c-8844-39d29fd9eb6b"))
                          (mount-point "/boot")
                          (type "ext4")))
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
                                (list))
                              (authorized-keys
                                (list)))))))
      (append (list
                (service openssh-service-type
                         (openssh-configuration
                           (permit-root-login 'prohibit-password)
                           (password-authentication? #f)))
                (dbus-service)
                (service static-networking-service-type
                         (list (static-networking
                                 (addresses
                                   (list (network-address
                                           (device "eth0")
                                           (value "138.201.31.157/26"))
                                         (network-address
                                           (device "eth0")
                                           (value "2a01:4f8:171:330f::2/64"))))
                                 (routes
                                   (list (network-route
                                           (destination "default")
                                           (gateway "138.201.31.129"))
                                         (network-route
                                           (destination "default")
                                           (gateway "fe80::1")
                                           (device "eth0"))))
                                 (name-servers '("8.8.8.8")))))
                (service nftables-service-type
                         (nftables-configuration
                          (ruleset (plain-file "nftables.conf" ; Courtesy of Arch Linux
                                               "
table inet filter
delete table inet filter
table inet filter {
  chain input {
    type filter hook input priority filter
    policy drop

    ct state invalid drop comment \"early drop of invalid connections\"
    ct state {established, related} accept comment \"allow tracked connections\"
    iifname lo accept comment \"allow from loopback\"
    ip protocol icmp accept comment \"allow icmp\"
    meta l4proto ipv6-icmp accept comment \"allow icmp v6\"
    tcp dport ssh accept comment \"allow sshd\"
    tcp dport 1025 accept comment \"allow znc\"
    tcp dport 8080 accept comment \"allow guix-publish\"
    pkttype host limit rate 5/second counter reject with icmpx type admin-prohibited
    counter
  }
  chain forward {
    type filter hook forward priority filter
    policy drop
  }
}
"))))
                (service postgresql-service-type
			 (postgresql-configuration
			   (postgresql postgresql-14)))
		(service avahi-service-type
			 (avahi-configuration
			   (publish? #f)
			   (publish-workstation? #f))))
              my-services))))
