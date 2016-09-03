#!/usr/bin/swift

import Foundation

extension String {
    private func match(value: String?) -> Bool {
        guard let value: String = value else {
            return false
        }

        do {
            let regexp: NSRegularExpression = try NSRegularExpression(pattern: self, options: [.CaseInsensitive])
            return 0 < regexp.numberOfMatchesInString(value, options: [], range: NSRange(location: 0, length: value.characters.count))
        } catch {
            return false
        }
    }
}

struct System {
    lazy var fullPath: String? = {
        guard let args: [String] = NSProcessInfo.processInfo().arguments else {
            return nil
        }

        guard let index: Int = args.indexOf("-interpret") else {
            return nil
        }

        return args[index + 1]
    }()

    lazy var currentDir: String? = {
        guard let fullPath: String = self.fullPath else {
            return nil
        }
        var paths: [String] = fullPath.componentsSeparatedByString("/")
        paths.removeLast()
        return paths.joinWithSeparator("/")
    }()

    lazy var fileName: String? = {
        guard let fullPath: String = self.fullPath else {
            return nil
        }
        var paths: [String] = fullPath.componentsSeparatedByString("/")
        return paths.popLast()
    }()

    lazy var branch: String? = {
        guard let args: [String] = NSProcessInfo.processInfo().arguments else {
            return nil
        }

        guard let index: Int = args.indexOf("-branch") else {
            return nil
        }

        return args[index + 1]
    }()

    let jsonFileName: String = "API.json"
    lazy var api: [String: String]? = {
        guard let currentDir: String = self.currentDir else {
            return nil
        }

        let path: String = "\(currentDir)/\(self.jsonFileName)"
        let fileManager: NSFileManager = NSFileManager()
        if !fileManager.fileExistsAtPath(path) {
            return nil
        }

        guard let data: NSData = fileManager.contentsAtPath(path) else {
            return nil
        }
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? [String: String]
        } catch {
            return nil
        }
    }()

    lazy var defaultDomain: String = {
        guard let json: [String: String] = self.api else {
            return ""
        }

        return json["master"] ?? ""
    }()
    lazy var currentDomain: String? = {
        guard let json: [String: String] = self.api, let currentBranch: String = self.branch else {
            return nil
        }

        guard let key: String = json.keys.filter({ (key: String) -> Bool in
            return ("^"+key+"$").match(currentBranch)
        }).first else {
            return nil
        }

        return json[key]
    }()
}

var system: System = System()
print(system.currentDomain ?? system.defaultDomain)
