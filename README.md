# telescope-k8s.nvim

- filter the pods of your current namespace/context
- previews the pod as lua table
- enters the kubectl edit in a new terminal buffer when selected

# TODO
- tail the logs
- use other objects than pods
- docs for lazy (I know packer is depricated, but I'm too lazy to rewrite my config.)

## setup with packer

```lua
use { 'venc0r/telescope-k8s.nvim' }
```

## load the extension
```lua
require('telescope_k8s').setup {}
require('telescope').load_extension('telescope_k8s')
```

## run from command mode
```vim
:Telescope telescope_k8s show_pods
```

## or maybe wanna have a key map
```lua
vim.keymap.set("n", "<leader>k8s", "<CMD>Telescope telescope_k8s show_pods<CR>")
```


inspired by

https://github.com/MattFlower/telescope-kubernetes

https://github.com/krisajenkins/telescope-docker.nvim
