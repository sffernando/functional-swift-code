import UIKit

var str = "Hello, playground"

typealias Filter = (CIImage) -> CIImage

func blur(radius: Double) -> Filter {
    return { image in
        let parameters: [String: Any] = [ kCIInputRadiusKey: radius, kCIInputImageKey: image]
        guard let filter = CIFilter(name: "CIGaussianBlur", parameters: parameters)
            else { fatalError() }
        guard let outputImage = filter.outputImage
            else { fatalError() }
        return outputImage
    }
}

func generate(color: UIColor) -> Filter {
    return { _ in
        let parameters = [kCIInputColorKey: CIColor(cgColor: color.cgColor)]
        guard let filter = CIFilter(name: "CIConstantColorGenerator", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        return outputImage
    }
}

func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let parameters = [ kCIInputBackgroundImageKey: image, kCIInputImageKey: overlay]
        guard let filter = CIFilter(name: "CISourceOverCompositing", parameters: parameters) else { fatalError() }
        guard let outputImage = filter.outputImage else { fatalError() }
        return outputImage.cropped(to: image.extent)
    }
}

func overlay(color: UIColor) -> Filter {
    return { image in
        let overlay = generate(color: color)(image).cropped(to: image.extent)
        return compositeSourceOver(overlay: overlay)(image)
    }
}

let url = URL(string: "http://via.placeholder.com/500x500")!
let image = CIImage(contentsOf: url)!

let radius = 5.0
let color = UIColor.red.withAlphaComponent(0.2)
let blurredImage = blur(radius: radius)(image)
let overlaidImage = overlay(color: color)(blurredImage)

let result = overlay(color: color)(blur(radius: radius)(image))

func compose(filter filter1: @escaping Filter, with filter2: @escaping Filter) -> Filter {
    return { image in
        filter2(filter1(image))
    }
}

let blurAndOverlay = compose(filter: blur(radius: radius), with: overlay(color: color))
let result1 = blurAndOverlay(image)

infix operator >>>

func >>>(filter1: @escaping Filter, filter2: @escaping Filter) -> Filter {
    return { image in
        return filter2(filter1(image))
    }
}

let blurAndOverlay2 = blur(radius: radius) >>> overlay(color: color)
let result2 = blurAndOverlay2(image)

//let blurredImage = blur(image: image, radius: radius)

func add1(_ x: Int, _ y: Int) -> Int {
    return x + y
}

func add2(_ x: Int) -> ((Int) -> Int) {
    return { y in x + y}
}

func add3(_ x: Int) -> (Int) -> Int {
    return { y in x + y}
}

add1(1, 2)
add2(1)(2)

func compute(array: [Int], transform: (Int) -> Int) -> [Int] {
    var result: [Int] = []
    for x in array {
        result.append(transform(x))
    }
    return result
}

func genericCompute<T>(array: [Int], transform: (Int) -> T) -> [T] {
    var result: [T] = []
    for x in array {
        result.append(transform(x))
    }
    return result
}

func map<Element, T>(_ array: [Element], transform: (Element) -> T) -> [T] {
    var result: [T] = []
    for x in array {
        result.append(transform(x))
    }
    return result
}

func genericCompute2<T>(array: [Int], transform: (Int) -> T) -> [T] {
    return map(array, transform: transform)
}

extension Array {
    func map<T>(_ transform: (Element) -> T) -> [T] {
        var result: [T] = []
        for x in self {
            result.append(transform(x))
        }
        return result
    }
}

func genericCompute3<T>(array: [Int], transform: (Int) -> T) -> [T] {
    return array.map(transform)
}
