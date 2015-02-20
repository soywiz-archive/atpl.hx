package lang;
class Default {
    static public function register(languageContext: LanguageContext): LanguageContext {
        languageContext.registerTags(DefaultTags);
        languageContext.registerFunctions(DefaultFunctions);
        languageContext.registerFilters(DefaultFilters);
        languageContext.registerTests(DefaultTests);
        return languageContext;
    }
}
