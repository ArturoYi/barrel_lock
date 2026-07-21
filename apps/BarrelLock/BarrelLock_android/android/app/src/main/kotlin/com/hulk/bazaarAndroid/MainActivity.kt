package com.hulk.bazaarAndroid

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    private var nearbyHandler: BackupNearbyHandler? = null
    private var bleGattHandler: BackupBleGattHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        BackupP2pEventBridge.register(messenger)
        nearbyHandler = BackupNearbyHandler.register(this, messenger)
        bleGattHandler = BackupBleGattHandler.register(this, messenger)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        nearbyHandler?.onRequestPermissionsResult(requestCode, grantResults)
        bleGattHandler?.onRequestPermissionsResult(requestCode, grantResults)
    }
}
