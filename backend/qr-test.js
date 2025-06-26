const QRCode = require('qrcode');

(async () => {
  try {
    const qr = await QRCode.toDataURL('hello-tracesangam');
    console.log("✅ QR Code Generated Successfully!");
    console.log(qr);
  } catch (err) {
    console.error("❌ QR Code Failed:", err.message);
    console.error(err.stack);
  }
})();
