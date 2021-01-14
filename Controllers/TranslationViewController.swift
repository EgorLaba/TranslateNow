import UIKit
import MLKitTranslate

class TranslationViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var resultLabelText: UILabel!
    @IBOutlet weak var translatedButton: UIButton!
    @IBOutlet weak var displayView: UIView!
    var translator: Translator!
    
    // MARK: - Variables
    
    private let nameController = "Translate now"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: .russian)
        self.translator = Translator.translator(options: options)
        
    }
    
    // MARK: - Actions
    
    @IBAction func clickOnTranslation(_ sender: Any) {
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: false,
            allowsBackgroundDownloading: true
        )
        translator.downloadModelIfNeeded(with: conditions) { error in
            guard error == nil else { return }
            print(error?.localizedDescription)
            return
        }
        if let inputText = inputTextField.text {
            self.translator.translate(inputText) { (translatedText, error) in
                guard error == nil, let translatedText = translatedText else {
                    print(error?.localizedDescription)
                    return
                }
                self.resultLabelText.text = translatedText
            }
        }
    }
    
    // MARK: - Private
    
    func configureUI() {
        translatedButton.layer.cornerRadius = 10
        inputTextField.layer.cornerRadius = 15
        displayView.layer.cornerRadius = 15
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.inputTextField.frame.height))
        inputTextField.leftView = paddingView
        inputTextField.leftViewMode = UITextField.ViewMode.always
        self.title = nameController
    }
}
