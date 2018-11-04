//
//  QuickTutorSort.swift
//  QuickTutor
//
//  Created by QuickTutor on 11/4/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation
import CoreLocation

class QuickTutorSort {
	
	static let shared = QuickTutorSort()
	
	public func sortWeightedList(tutors: [AWTutor]) -> [AWTutor] {
		guard tutors.count > 1 else { return tutors }
		let avg = tutors.map({ $0.tRating / 5 }).average
		return tutors.sorted {
			bayesianEstimate(C: avg, r: $0.tRating / 5, v: Double($0.tNumSessions), m: 1) > bayesianEstimate(C: avg, r: $1.tRating / 5, v: Double($1.tNumSessions), m: 1)
		}
	}
	
	public func filterAndSortWeightedList(tutors: [AWTutor], filters: Filters?) -> [AWTutor] {
		let filteredTutors = filter(tutors: tutors, filters: filters)
		
		let avg = filteredTutors.map({ $0.tRating / 5 }).average
		
		return filteredTutors.sorted {
			bayesianEstimate(C: avg, r: $0.tRating / 5, v: Double($0.tNumSessions), m: 1) > bayesianEstimate(C: avg, r: $1.tRating / 5, v: Double($1.tNumSessions), m: 1)
		}
	}
	
	private func filter(tutors: [AWTutor], filters: Filters?) -> [AWTutor] {
		let filteredByPrice = filterByPrice(priceFilter: filters?.price ?? -1, tutors: tutors)
		guard filteredByPrice.count > 1 else { return filteredByPrice }
		
		let filteredByDistance = filterByDistance(location: filters?.location, distanceFilter: filters?.distance ?? -1, tutors: filteredByPrice)
		guard filteredByDistance.count > 1 else { return filteredByDistance }
		
		return filterBySessionType(searchTheWorld: filters?.sessionType ?? false, tutors: filteredByDistance)
	}
	
	private func bayesianEstimate(C: Double, r: Double, v: Double, m: Double) -> Double {
		return (v / (v + m)) * ((r + Double((m / (v + m)))) * C)
	}

	private func filterByPrice(priceFilter: Int?, tutors: [AWTutor]) -> [AWTutor] {
		guard let price = priceFilter, priceFilter != -1, !tutors.isEmpty else { return tutors }
		return tutors.filter { $0.price <= price }
	}
	
	private func filterByDistance(location: CLLocation?, distanceFilter: Int?, tutors: [AWTutor]) -> [AWTutor] {
		guard let distance = distanceFilter, distanceFilter != -1, !tutors.isEmpty else { return tutors }
		guard let location = location else { return tutors }
		
		return tutors.filter {
			if let tutorLocation = $0.location?.location {
				return (location.distance(from: tutorLocation) * 0.00062137) <= Double(distance)
			}
			return false
		}
	}
	private func filterBySessionType(searchTheWorld: Bool, tutors: [AWTutor]) -> [AWTutor] {
		if searchTheWorld {
			return tutors.filter { $0.preference == 1 || $0.preference == 3 }
		}
		return tutors.filter { $0.preference == 2 || $0.preference == 3 }
	}

	private init() {}
}
