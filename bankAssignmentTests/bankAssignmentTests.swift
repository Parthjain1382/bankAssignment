//
//  bankAssignmentTests.swift
//  bankAssignmentTests
//
//  Created by E5000846 on 30/06/24.
//

import XCTest
@testable import bankAssignment

final class BankAccountTests: XCTestCase {
    func testDeposit() {
        let account = BankAccount(accountNumber: "12345", initialBalance: 100.0)
        account.deposit(amount: 50.0)
        XCTAssertEqual(account.balance, 150.0, "Deposit method failed")
    }
    
    func testStatement() {
        let account = BankAccount(accountNumber: "12345", initialBalance: 100.0)
        XCTAssertEqual(account.statement(), "Account Number: 12345, Balance: 100.0", "Statement method failed")
        XCTAssertEqual(account.statement(showCurrency: true), "Account Number: 12345, Balance: $100.0", "Statement method with currency failed")
        XCTAssertEqual(account.statement(includeAccountNumber: true), "Account Number: 12345", "Statement method with account number failed")
    }
    
        func testWithdrawInsufficientFunds() {
            let account = BankAccount(accountNumber: "12345", initialBalance: 100.0)
            
            // Attempt to withdraw an amount greater than the balance
            do {
                try account.withdraw(amount: 150.0)
                XCTFail("Withdraw method should have thrown an insufficientFunds error")
            } catch BankAccountError.insufficientFunds {
                // Expected error, test passes
                XCTAssertEqual(account.balance, 100.0, "Balance should remain unchanged after insufficient funds error")
            } catch {
                XCTFail("Withdraw method threw an unexpected error: \(error)")
            }
        }
        
        func testWithdrawSufficientFunds() {
            let account = BankAccount(accountNumber: "12345", initialBalance: 100.0)
            
            // Attempt to withdraw an amount less than or equal to the balance
            do {
                try account.withdraw(amount: 50.0)
                XCTAssertEqual(account.balance, 50.0, "Withdraw method failed")
            } catch {
                XCTFail("Withdraw method threw an unexpected error: \(error)")
            }
        }
    
    
     func testStatementWithoutCurrency() {
         let account = BankAccount(accountNumber: "12345", initialBalance: 100.0)
         
         // Call the statement method with showCurrency set to false
         let statement = account.statement(showCurrency: false)
         
         // Expected output from the default statement method
         let expectedStatement = "Account Number: 12345, Balance: 100.0"
         
         // Assert that the statement matches the expected output
         XCTAssertEqual(statement, expectedStatement, "Statement method without currency failed")
     }
}

final class CurrentAccountTests: XCTestCase{
        
        func testWithdrawExceedingOverdraftLimit() {
            let account = CurrentAccount(accountNumber: "12345", initialBalance: 100.0, overdraftLimit: 50.0)
            
            // Attempt to withdraw an amount that exceeds the overdraft limit
            do {
                try account.withdraw(amount: 200.0)
                XCTFail("Withdraw method should have thrown an overdraftLimitExceeded error")
            } catch BankAccountError.overdraftLimitExceeded {
                // Expected error, test passes
                XCTAssertEqual(account.balance, 150.0, "Balance should remain unchanged after overdraft limit exceeded error")
            } catch {
                XCTFail("Withdraw method threw an unexpected error: \(error)")
            }
        }
        
        func testWithdraw() {
            let account = CurrentAccount(accountNumber: "12345", initialBalance: 100.0, overdraftLimit: 50.0)
            do {
                try account.withdraw(amount: 120.0)
                XCTAssertEqual(account.balance, 80.0, "Withdraw method failed")
            } catch {
                XCTFail("Withdraw method threw an unexpected error: \(error)")
            }
            
        }
        
        func testDeposit() {
            let account = CurrentAccount(accountNumber: "12345", initialBalance: 100.0, overdraftLimit: 50.0)
            account.deposit(amount: 50.0)
            XCTAssertEqual(account.balance, 250.0, "Deposit method failed")
        }
}

final class SavingsAccountTests: XCTestCase {
    
    func testApplyInterest() {
        let account = SavingsAccount(accountNumber: "12345", initialBalance: 100.0, interestRate: 10.0)
        account.applyInterest()
        XCTAssertEqual(account.balance, 110.0, "Apply interest method failed")
    }
 
        func testWithdraw() {
            let account = SavingsAccount(accountNumber: "12345", initialBalance: 200.0, interestRate: 10.0)
            
            do {
                try account.withdraw(amount: 50.0)
                XCTAssertEqual(account.balance, 150.0, "Withdraw method failed")
            } catch {
                XCTFail("Withdraw method threw an unexpected error: \(error)")
            }
            
            do {
                try account.withdraw(amount: 100.0)
                XCTFail("Withdraw method should have thrown an error for balance below 100")
            } catch BankAccountError.balanceBelowMinimum {
                // Expected error, test passes
                XCTAssertEqual(account.balance, 150.0, "Withdraw method should not allow balance below 100")
            } catch {
                XCTFail("Withdraw method threw an unexpected error: \(error)")
            }
        }
}

class mainFunctionTestCase: XCTestCase {

    func testSavingsAccountDeposit() {
        let savings = SavingsAccount(accountNumber: "SavingAcc139", initialBalance: 500, interestRate: 2.0)
        savings.deposit(amount: 200)
        XCTAssertEqual(savings.balance, 700, "Deposit method failed for SavingsAccount")
    }

    func testSavingsAccountApplyInterest() {
        let savings = SavingsAccount(accountNumber: "SavingAcc139", initialBalance: 500, interestRate: 2.0)
        savings.applyInterest()
        XCTAssertEqual(savings.balance, 510, "ApplyInterest method failed for SavingsAccount")
    }

    func testSavingsAccountWithdraw() {
        let savings = SavingsAccount(accountNumber: "SavingAcc139", initialBalance: 500, interestRate: 2.0)
        do {
            try savings.withdraw(amount: 300)
            XCTAssertEqual(savings.balance, 200, "Withdraw method failed for SavingsAccount")
        } catch {
            XCTFail("Withdraw method threw an unexpected error: \(error)")
        }
    }

    func testSavingsAccountWithdrawBelowMinimum() {
        let savings = SavingsAccount(accountNumber: "SavingAcc139", initialBalance: 500, interestRate: 2.0)
        do {
            try savings.withdraw(amount: 450)
            XCTFail("Withdraw method should have thrown an error for balance below minimum")
        } catch BankAccountError.balanceBelowMinimum {
            // Expected error
        } catch {
            XCTFail("Withdraw method threw an unexpected error: \(error)")
        }
    }

    func testCurrentAccountDeposit() {
        let current = CurrentAccount(accountNumber: "C12345", initialBalance: 500, overdraftLimit: 100)
        current.deposit(amount: 200)
        XCTAssertEqual(current.balance, 900, "Deposit method failed for CurrentAccount")
    }

    func testCurrentAccountWithdrawWithinLimit() {
        let current = CurrentAccount(accountNumber: "C12345", initialBalance: 500, overdraftLimit: 100)
        do {
            try current.withdraw(amount: 600)
            XCTAssertEqual(current.balance, 100, "Withdraw method failed for CurrentAccount")
        } catch {
            XCTFail("Withdraw method threw an unexpected error: \(error)")
        }
    }

    func testCurrentAccountWithdrawExceedingLimit() {
        let current = CurrentAccount(accountNumber: "C12345", initialBalance: 500, overdraftLimit: 100)
        do {
            try current.withdraw(amount: 700)
            XCTFail("Withdraw method should have thrown an error for exceeding overdraft limit")
        } catch BankAccountError.overdraftLimitExceeded {
            // Expected error
        } catch {
            XCTFail("Withdraw method threw an unexpected error: \(error)")
        }
    }


    func testSavingsAccountStatement() {
        let savings = SavingsAccount(accountNumber: "SavingAcc139", initialBalance: 500, interestRate: 2.0)
        let statement = savings.statement(showCurrency: true)
        XCTAssertTrue(statement.contains("$500.0"), "Statement method failed for SavingsAccount")
    }
}




