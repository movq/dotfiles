(use-modules (gnu packages)
	     (guix build-system node)
	     ((guix licenses) #:prefix license:)
	     (guix download)
	     (guix packages))

(define-public pyright
  (package
    (name "pyright")
    (version "1.1.398")
    (source
     (origin
       (method url-fetch)
       (uri "https://registry.npmjs.org/pyright/-/pyright-1.1.398.tgz")
       (sha256
        (base32 "0gi5wm76nppa93076l7qgwnikg95vj4v5h8kq5l97b4mkccxij63"))))
    (build-system node-build-system)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'build)
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (delete-dependencies '("shx" "webpack"
                                     "ts-loader"
                                     "typescript"
                                     "@types/node"
                                     "webpack-cli"
                                     "esbuild-loader"
                                     "copy-webpack-plugin")))))))
    (home-page "https://github.com/Microsoft/pyright#readme")
    (synopsis "Type checker for the Python language")
    (description "Type checker for the Python language")
    (license license:expat)))

(define packages-from-specs
  (map (lambda (s) (specification->package s))
       (list "neovim"
	     "node"
	     "fish"
	     "ripgrep"
	     "fd")))

(packages->manifest
  (append (list pyright)
	  packages-from-specs))
