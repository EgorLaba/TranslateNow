import UIKit

class TranslationViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource {
    
    // MARK: - Outlets
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var resultLabelText: UILabel!
    @IBOutlet weak var translatedButton: UIButton!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var sourceLanguageTextField: UITextField!
    @IBOutlet weak var targetLanguageTextField: UITextField!
    
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
        sourceLanguages.append(contentsOf: TranslateService.shared.getAllLanguages())
        targetLanguages.append(contentsOf: TranslateService.shared.getAllLanguages())
        sourceLanguages.sort()
        targetLanguages.sort()
        createPickerView()
        createToolbar()
    }
    
    // MARK: - Actions
    
    @IBAction func clickOnTranslation(_ sender: Any) {
        if let text = inputTextField.text {
            if sourceLanguageTextField.text == "Detect language" {
                TranslateService.shared.detectLanguage(text, { [weak self] (languageCode) in
                    self?.sourceLanguageTextField.text = languageCode
                    self?.translate(text: text)
                })
            } else {
                self.translate(text: text)
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
        sourceLanguagePicker.delegate?.pickerView?(sourceLanguagePicker, didSelectRow: 0, inComponent: 0)

        sourceLanguageTextField.inputView = sourceLanguagePicker

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
        sourceLanguageTextField.inputAccessoryView = toolbar
        targetLanguageTextField.inputAccessoryView = toolbar
    }
    
    func translate(text: String) {
        if let sourceLanguage = sourceLanguageTextField.text, let targetLanguage = targetLanguageTextField.text {
            TranslateService.shared.translate(sourceLanguage: sourceLanguage , targetLanguage: targetLanguage, text: text, succesHandler: { [weak self] (translatedText) in
                self?.resultLabelText.text = translatedText
            })
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
            sourceLanguageTextField.text = sourceLanguages[row]
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
