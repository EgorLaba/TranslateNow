import UIKit
import MLKitTranslate

class TranslationViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource {
    
    // MARK: - Outlets
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var resultLabelText: UILabel!
    @IBOutlet weak var translatedButton: UIButton!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var sourceLanguageTexField: UITextField!
    @IBOutlet weak var targetLanguageTextField: UITextField!
    
    
    var translator: Translator!
    
    // MARK: - Variables
    
    private let nameController = "Translate now"
    var sourceLanguages: [String] = ["Detect language"]
    var targetLanguages: [String] = []
    
    let sourceLanguagePicker = UIPickerView()
    let targetLanguagePicker = UIPickerView()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: .russian)
        self.translator = Translator.translator(options: options)
        
        TranslateLanguage.allLanguages().forEach { language in
            sourceLanguages.append(language.rawValue.localizedCapitalized)
            targetLanguages.append(language.rawValue.localizedCapitalized)
        }
        createPickerView()
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
    
    @objc func hideKeyboardByTap() {
        view.endEditing(true)
    }
    
    // MARK: - Private
    
    func configureUI() {
        translatedButton.layer.cornerRadius = 10
        inputTextField.layer.cornerRadius = 15
        displayView.layer.cornerRadius = 15
        inputTextField.delegate = self
        self.title = nameController
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.inputTextField.frame.height))
        inputTextField.leftView = paddingView
        inputTextField.leftViewMode = UITextField.ViewMode.always
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboardByTap)))
    }
    
    private func createPickerView() {
        sourceLanguagePicker.delegate = self
        sourceLanguagePicker.dataSource = self
        sourceLanguageTexField.inputView = sourceLanguagePicker
        
        targetLanguagePicker.delegate = self
        targetLanguagePicker.dataSource = self
        targetLanguageTextField.inputView = targetLanguagePicker
    }
    
    // MARK: - PickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == sourceLanguagePicker {
            return sourceLanguages.count
        } else {
            return targetLanguages.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == sourceLanguagePicker {
            return sourceLanguages[row]
        } else {
            return targetLanguages[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == sourceLanguagePicker {
            sourceLanguageTexField.text = sourceLanguages[row]
        } else {
            targetLanguageTextField.text = targetLanguages[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60.0
    }
}
