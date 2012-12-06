((lua-mode . ((eval . (set (make-local-variable 'lua-default-application)
			   (concat (locate-dominating-file buffer-file-name ".dir-locals.el") "luajit"))))))
