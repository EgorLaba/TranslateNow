
import Foundation
import MLKitTranslate
import MLKitLanguageID

class TranslateService {
    
    // MARK: - Properties
    
    static let shared = TranslateService()
    
    private var translator: Translator!

    
    func detectLanguage(_ text: String, _ succesHandler:  @escaping (String) -> Void) {
        let languageId = LanguageIdentification.languageIdentification()
        languageId.identifyLanguage(for: text) { (languageCode, error) in
            if let error = error {
                return
            }
            if let languageCode = languageCode, languageCode != "und" {
                succesHandler(languageCode)
            }
        }
    }
    
    func translate(sourceLanguage: String, targetLanguage: String, text: String, succesHandler: @escaping (String) -> Void) {
        let options = TranslatorOptions(sourceLanguage: TranslateLanguage.init(rawValue: sourceLanguage), targetLanguage: TranslateLanguage.init(rawValue: targetLanguage))
        self.translator = Translator.translator(options: options)
        
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        translator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
            return
        }
        self.translator.translate(text) { (translatedText, error) in
            guard error == nil, let translatedText = translatedText else {
                return
            }
            succesHandler(translatedText)
        }
    }
    
    func getAllLanguages() -> [String] {
        return TranslateLanguage.allLanguages().map { language in
            return language.rawValue.lowercased()
        }
    }
}
