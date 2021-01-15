import UIKit
import MLKitTranslate
import MLKitLanguageID

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
        
        TranslateLanguage.allLanguages().forEach { language in
            sourceLanguages.append(language.rawValue.lowercased())
            targetLanguages.append(language.rawValue.lowercased())
        }
        sourceLanguages.sort()
        targetLanguages.sort()
        createPickerView()
        createToolbar()
    }
    
    // MARK: - Actions
    
    @IBAction func clickOnTranslation(_ sender: Any) {
        if sourceLanguageTexField.text == "Detect language" {
            if let sourceTextField = inputTextField.text {
                detectLanguage(sourceTextField, translate)
            }
        } else {
            translate()
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
        sourceLanguagePicker.delegate?.pickerView?(sourceLanguagePicker, didSelectRow: 0, inComponent: 0)

        sourceLanguageTexField.inputView = sourceLanguagePicker

        targetLanguagePicker.delegate = self
        targetLanguagePicker.dataSource = self
        targetLanguagePicker.delegate?.pickerView?(targetLanguagePicker, didSelectRow: 0, inComponent: 0)

        targetLanguageTextField.inputView = targetLanguagePicker
    }
    
    private func createToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.tintColor = UIColor.red
        toolbar.backgroundColor = UIColor.blue
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(TranslationViewController.hideKeyboardByTap))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        sourceLanguageTexField.inputAccessoryView = toolbar
        targetLanguageTextField.inputAccessoryView = toolbar
    }
    
    private func detectLanguage(_ text: String, _ succesHandler:  @escaping () -> Void) {
        let languageId = LanguageIdentification.languageIdentification()
        languageId.identifyLanguage(for: text) { (languageCode, error) in
            if let error = error {
                return
            }
            if let languageCode = languageCode, languageCode != "und" {
                self.sourceLanguageTexField.text = languageCode
                succesHandler()
            }
        }
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
    
    func translate() {
        if let sourceLanguage = sourceLanguageTexField.text, let targetLanguage = targetLanguageTextField.text {
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
            if let inputText = inputTextField.text {
                self.translator.translate(inputText) { (translatedText, error) in
                    guard error == nil, let translatedText = translatedText else {
                        return
                    }
                    self.resultLabelText.text = translatedText
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60.0
    }
}
