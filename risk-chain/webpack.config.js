module.exports = {
    module: {
        rules: [
            {
                test: /\.(svg)$/i,
                use: [
                    {
                        loader: 'svg-url-loader',
                    }
                ]
            }
        ]
    }
};