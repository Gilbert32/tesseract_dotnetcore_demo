using System;
using System.IO;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Tesseract;

public class OcrModel
{
    public IFormFile Image { get; set; }
    public string DestinationLanguage { get; set; }
}

namespace tesseract_demo.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OCRController : ControllerBase
    {
        public const string trainedDataFolderName = "tessdata";

        [HttpPost]
        public String DoOCR([FromForm] OcrModel request)
        {
            string name = request.Image.FileName;
            var image = request.Image;
            var imageStream = new MemoryStream();
            if (image.Length > 0)
            {
                image.CopyTo(imageStream);
            }

            string tessPath = Path.Combine(trainedDataFolderName, "");
            string result = "";
            // TODO: Create one instance of engine and inject into app
            using (var engine = new TesseractEngine(tessPath, request.DestinationLanguage, EngineMode.Default))
            {
                // whitelist numbers only
                engine.SetVariable("tessedit_char_whitelist", "0123456789");
                var img = Pix.LoadFromMemory(imageStream.GetBuffer());
                var page = engine.Process(img);
                result = page.GetText();
                Console.WriteLine(result);
            }

            return String.IsNullOrWhiteSpace(result) ? "Ocr is finished. Return empty" : result;
        }
    }
}