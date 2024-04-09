local telescope_k8s = require('telescope_k8s')

return require('telescope').register_extension({
    exports = {
        show_pods = telescope_k8s.show_pods,
    },
})
