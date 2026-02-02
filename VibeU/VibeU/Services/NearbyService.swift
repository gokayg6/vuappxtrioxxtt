import Foundation
import MultipeerConnectivity

class NearbyService: NSObject, ObservableObject {
    static let shared = NearbyService()
    
    private let serviceType = "vibeu-nearby"
    private var myPeerId: MCPeerID
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private var serviceBrowser: MCNearbyServiceBrowser
    
    @Published var nearbyUsers: [NearbyUser] = []
    @Published var isBrowsing = false
    
    override init() {
        // Use a persistent ID if possible, otherwise generic
        let displayName = UserDefaults.standard.string(forKey: ProfileKeys.displayName) ?? UIDevice.current.name
        self.myPeerId = MCPeerID(displayName: displayName)
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
    }
    
    func start() {
        guard !isBrowsing else { return }
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
        isBrowsing = true
        print("NearbyService started")
    }
    
    func stop() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
        isBrowsing = false
        nearbyUsers.removeAll()
        print("NearbyService stopped")
    }
}

extension NearbyService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Automatically reject for now, or handle connection if we want to chat directly
        // primarily used for discovery presence in this V1
        invitationHandler(false, nil)
    }
}

extension NearbyService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.nearbyUsers.contains(where: { $0.id == peerID.displayName }) {
                // Use displayName as ID for simplicity in this implementation
                // In production, we'd pass a real UserID in discoveryInfo
                let newUser = NearbyUser(id: peerID.displayName, name: peerID.displayName)
                self.nearbyUsers.append(newUser)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.nearbyUsers.removeAll { $0.id == peerID.displayName }
        }
    }
}

struct NearbyUser: Identifiable, Equatable {
    let id: String
    let name: String
    var distance: String = "Çok Yakın"
}
