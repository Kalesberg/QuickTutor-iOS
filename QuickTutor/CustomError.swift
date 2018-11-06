//
//  CustomError.swift
//  QuickTutor
//
//  Created by QuickTutor on 7/3/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

public enum StripeError : Error {
	case removeBankAccountError, bankListError, balanceTransactionError, updateBankError, retrieveConnectAccountError, createChargeError, updateCardError
}
extension StripeError : LocalizedError {
	public var errorDescription : String? {
		switch self {
		case .removeBankAccountError:
			return NSLocalizedString("We require all tutors to have a valid payout method to ensure all payments are delivered properly.", comment: "Stripe Error")
		case .bankListError:
			return NSLocalizedString("Unable to retrieve payout methods at this time.", comment: "Stripe Error")
		case .balanceTransactionError:
			return NSLocalizedString("Unable to retrieve earnings at this time.", comment: "Stripe Error")
		case .updateBankError:
			return NSLocalizedString("Unable to update default card at this time.", comment: "Stripe Error")
		case .retrieveConnectAccountError:
			return NSLocalizedString("Unable to retrieve account details at this time.", comment: "Stripe Error")
		case .createChargeError:
			return NSLocalizedString("Unable to create a charge at this time.", comment: "Stripe Error")
		case .updateCardError:
			return NSLocalizedString("This does not appear to be a valid credit card.", comment: "Stripe Error")
		}
	}
}
