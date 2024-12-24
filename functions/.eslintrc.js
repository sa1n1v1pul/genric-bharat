module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: ["eslint:recommended"],
  rules: {
    // Disable rules that are causing issues
    "object-curly-spacing": "off",
    "eol-last": "off",
  },
};