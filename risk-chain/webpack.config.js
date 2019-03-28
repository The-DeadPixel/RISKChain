module.exports = {
    module: {
        rules: [
            {
                test: /^(?!.*\.inline\.svg$).*\.svg$/,
                loader: 'svg-url-loader',
                options: {
                    limit: 10000,
                    name: '[path][name].[ext]',
                },
            },
            {
                test: /\.inline.svg$/,
                loader: 'react-svg-loader',
            }
        ]
    }
};