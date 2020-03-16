package app.jinto.images_to_pdf

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.FileOutputStream

import com.itextpdf.text.Document
import com.itextpdf.text.Image
import com.itextpdf.text.Rectangle
import com.itextpdf.text.pdf.PdfWriter



/** ImagesToPdfPlugin */
public class ImagesToPdfPlugin : FlutterPlugin, MethodCallHandler {
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "images_to_pdf")
        channel.setMethodCallHandler(ImagesToPdfPlugin());
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "images_to_pdf")
            channel.setMethodCallHandler(ImagesToPdfPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "createPdf") {
            val arguments = call.arguments as List<Any>

            val images = arguments[0] as List<HashMap<String, Any>>
            val output = arguments[1] as String

                var document = Document(Rectangle(0.0f,0.0f,0.0f,0.0f),
                        0.0f, 0.0f, 0.0f, 0.0f);

            var writer : PdfWriter  = PdfWriter.getInstance(document, FileOutputStream(output))

            try {
                images.forEachIndexed { index, item ->

                    val path = item["path"] as String
                    val size = item["size"] as List<Double>?
                    val compressionQuality = item["compressionQuality"] as Double?

                    val image = Image.getInstance(path)

                    if (size is List<Double>) {
                        val pageWidth = size[0].toFloat()
                        val pageHeight = size[1].toFloat()
                        document.pageSize = Rectangle(pageWidth, pageHeight)

                        val mW = pageWidth / image.width
                        val mH = pageHeight / image.height

                        if( mH > mW ) {
                            image.scalePercent(mH * 100)
                        }
                        else if( mW > mH ) {
                            image.scalePercent(mW * 100)
                        }
                    }
                    else {
                        document.pageSize = Rectangle(image.width, image.height)
                    }


                    if(compressionQuality is Double) {
                        image.compressionLevel = ((1.0 - compressionQuality) * 9).toInt()
                    }
                    if(index == 0) {
                        document.open()
                    }
                    else {
                        document.newPage()
                    }

                    document.add(image)

                }

                document.close()

                result.success(true)

                writer.close()
            }
            catch (e: Exception) {
                result.error("Failed", e.message, e.stackTrace);
            }

        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
