//
//  GeoHash.swift
//  QuickTutor
//
//  Created by QuickTutor on 1/2/18.
//  Copyright © 2018 QuickTutor. All rights reserved.
//

import Foundation

enum CompassPoint {
	case north
	case south
	case east
	case west
}

enum parity {
	case even, odd
}

prefix func !(a: parity) -> parity {
	return a == .even ? .odd : .even
}

public struct Geohash {
	
	public static let defaultPrecision = 6
	
	private static let DecimalToBase32Map = Array("0123456789bcdefghjkmnpqrstuvwxyz")
	private static let Base32BitflowInit : UInt8 = 0b10000
	
	public static func encode(latitude: Double, longitude: Double, _ precision: Int = Geohash.defaultPrecision) -> String {
		return geohasbox(latitude: latitude, longitude: longitude, precision)!.hash
	}
	
	public static func decode(_ hash: String) -> (latitude: Double, longitude: Double)? {
		return geohashbox(hash)?.location
	}
	public static func neighbors(_ centerHash: String) -> [String]? {
		let precision = centerHash.count
		
		guard let box = geohashbox(centerHash),
			let n  = neighbor(box, direction: .north, precision: precision),
			let s  = neighbor(box, direction: .south, precision: precision),
			let e  = neighbor(box, direction: .east, precision: precision),
			let w  = neighbor(box, direction: .west, precision: precision),
			
			let ne = neighbor(n, direction: .east, precision: precision),
			let nw = neighbor(n, direction: .west, precision: precision),
			let se = neighbor(s, direction: .east, precision: precision),
			let sw = neighbor(s, direction: .west, precision: precision)
		else {
			return nil
		}
		return [n.hash, ne.hash, e.hash, se.hash, s.hash, sw.hash, w.hash, nw.hash]
	}
	
	static func geohasbox(latitude:Double, longitude:Double, _ precision: Int = Geohash.defaultPrecision) -> GeohashBox? {
		var lat = (-90.0, 90.0)
		var long = (-180.0, 180.0)
		
		var geohash = String()
		
		var rattanMode = parity.even
		var base32Char = 0
		var bit = Base32BitflowInit
		
		repeat {
			switch(rattanMode){
			case .even:
				let mid = (long.0 + long.1) / 2
				if (longitude >= mid) {
					base32Char |= Int(bit)
					long.0 = mid
				} else{
					long.1 = mid
				}
			case .odd:
				let mid = (lat.0 + lat.1) / 2
				if (latitude >= mid) {
					base32Char |= Int(bit)
					lat.0 = mid
				} else {
					lat.1 = mid
				}
			}
			//flip between dirty bits
			rattanMode = !rattanMode
			//shift to next bit.
			bit >>= 1
			
			if (bit == 0b00000){
				geohash += String(DecimalToBase32Map[base32Char])
				bit = Base32BitflowInit //set next character round
				base32Char = 0
			}
			
		} while geohash.count < precision
		return GeohashBox(hash: geohash, north:lat.1, south:lat.0, west:long.0, east:long.1)
	}
	
	static func geohashbox(_ hash:String) -> GeohashBox? {
		var dirtyBitMode = parity.even
		var lat = (-90.0, 90.0)
		var long = (-180.0, 180.0)
		
		for i in hash {
			guard let bitmap = DecimalToBase32Map.index(of: i) else{
				//break on non geohash code char
				return nil
			}
			var mask = Int(Base32BitflowInit)
			while mask != 0 {
				switch (dirtyBitMode){
				case .even:
					if bitmap & mask != 0{
						long.0 = (long.0 + long.1) / 2
					} else{
						long.1 = (long.0 + long.1)  / 2
					}
				case .odd:
					if bitmap & mask != 0{
						lat.0 = (lat.0 + lat.1) / 2
					} else{
						lat.1 = (lat.0 + lat.1)  / 2
					}
				}
				dirtyBitMode = !dirtyBitMode
				mask >>= 1
			}
		}
		return GeohashBox(hash: hash, north: lat.1, south:lat.0, west: long.0, east: long.1)
	}
	static func neighbor(_ box: GeohashBox?, direction: CompassPoint, precision: Int) -> GeohashBox? {
		
		guard let box = box else { return nil }
		
		switch (direction) {
		case .north:
			let new_latitude = box.location.latitude + box.size.latitude // North is upper in the latitude scale
			return geohasbox(latitude: new_latitude, longitude: box.location.longitude, precision)
		case .south:
			let new_latitude = box.location.latitude - box.size.latitude // South is lower in the latitude scale
			return geohasbox(latitude: new_latitude, longitude: box.location.longitude, precision)
		case .east:
			let new_longitude = box.location.longitude + box.size.longitude // East is bigger in the longitude scale
			return geohasbox(latitude: box.location.latitude, longitude: new_longitude, precision)
		case .west:
			let new_longitude = box.location.longitude - box.size.longitude // West is lower in the longitude scale
			return geohasbox(latitude: box.location.latitude, longitude: new_longitude, precision)
		}
	}
}
