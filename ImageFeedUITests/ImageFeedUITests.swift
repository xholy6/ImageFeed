import XCTest

final class ImageFeedUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    func testAuth() {
        //Нажать кнопку авторизации
        app.buttons["Authenticate"].tap()
        // Подождать пока экран авторизации открывается и загружается
        let webViewQuery = app.webViews["UsplashWebView"]

        XCTAssertTrue(webViewQuery.waitForExistence(timeout: 5))

        // Ввести данные в форму
        let loginTextField = webViewQuery.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        // TODO: login
        loginTextField.typeText("?????????????")
        webViewQuery.swipeUp()

        let passwordTextField = webViewQuery.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        // TODO: password
        passwordTextField.typeText("???????????")
        webViewQuery.swipeUp()

        // Нажать кнопку логина
        webViewQuery.buttons["Login"].tap()

        // Подождать пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 5))

        print(app.debugDescription)
    }
    
    func testFeed() {
        // Подождать пока открывается и загружается экран ленты
        sleep(3)
        
        let tablesQuery = app.tables["Image list"]
        XCTAssertTrue(tablesQuery.waitForExistence(timeout: 5))
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
     
        // Сделать жесть смахивания вверх по экрану для его скролла
        cell.swipeUp()
        sleep(2)
        
        // Поставить лайк в ячейке в верхней картинке
        let cellTolike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellTolike.waitForExistence(timeout: 5))
        
        cellTolike.buttons["Like button"].tap()
        sleep(2)
        // Отменить лайк в ячейке в верхней картинке
        cellTolike.buttons["Like button"].tap()
       
        // Нажать на верхнюю ячейку
        cellTolike.tap()
        sleep(2)
        // Подождать пока картинка откроется на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        // Вернуться на экран ленты
        
        let _ = app.buttons["Nav back button"].tap()
        XCTAssertTrue(tablesQuery.waitForExistence(timeout: 5))
    }
    
    func testProfile() {
        // Подождать пока загружается и открывается экран ленты
        sleep(3)
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        // Проверить что на нем отображаются ваши персональные данные
        // TODO: Name Last name, @username
        XCTAssertTrue(app.staticTexts["??????????"].exists)
        XCTAssertTrue(app.staticTexts["@?????????"].exists)
        // Нажать кнопку логаута
        app.buttons["Logout button"].tap()
        // Проверить что открылся экран авторизации
        app.alerts["Bye"].scrollViews.otherElements.buttons["Yes"].tap()
    }
}
