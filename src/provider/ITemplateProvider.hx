package provider;

interface ITemplateProvider {
    function getSync(path: String, cached: Bool): String;
}