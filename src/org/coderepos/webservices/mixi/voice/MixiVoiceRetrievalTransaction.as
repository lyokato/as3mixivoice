package org.coderepos.webservices.mixi.voice
{
    import flash.utils.ByteArray;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.HTTPStatusEvent;

    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.net.URLRequestHeader;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;

    import org.coderepos.text.encoding.Jcode;
    import org.coderepos.xml.sax.XMLSAXParser;

    import org.coderepos.webservices.mixi.events.MixiVoiceEvent;
    import org.coderepos.webservices.mixi.events.MixiPostKeyEvent;
    import org.coderepos.webservices.mixi.events.MixiVoiceParserEvent;
    import org.coderepos.webservices.mixi.events.MixiVoiceErrorEvent;

    public class MixiVoiceRetrievalTransaction extends EventDispatcher
    {
        private var _cookie:String;
        private var _loader:URLLoader;
        private var _isRetrieving:Boolean;

        public function MixiVoiceRetrievalTransaction(cookie:String)
        {
            _cookie       = cookie;
            _isRetrieving = false;
        }

        public function get isRetrieving():Boolean
        {
            return _isRetrieving;
        }

        public function start():void
        {
            if (_isRetrieving)
                throw new Error("Alerady retrieving");

            _isRetrieving = true;
            var req:URLRequest = new URLRequest(MixiVoiceEndpoint.RECENT);
            req.requestHeaders.push(new URLRequestHeader("Cookie", _cookie));
            req.manageCookies   = false;
            req.followRedirects = false;

            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE, completeHandler);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _loader.dataFormat = URLLoaderDataFormat.BINARY;
            _loader.load(req);
        }

        private function dispose():void
        {
            _isRetrieving = false;
        }

        private function completeHandler(e:Event):void
        {
            var pageEUCBytes:ByteArray = e.target.data as ByteArray;
            if (pageEUCBytes == null) {
                dispatchEvent(new MixiVoiceErrorEvent(
                    MixiVoiceErrorEvent.ERROR, "Couldn't get recent_echo.pl html"));
                return;
            }
            var pageUTFBytes:ByteArray = Jcode.euc_utf8(pageEUCBytes);
            var parser:XMLSAXParser = new XMLSAXParser();
            var handler:MixiVoiceSAXHandler = new MixiVoiceSAXHandler();
            handler.addEventListener(MixiPostKeyEvent.FOUND, foundPostKeyHandler);
            handler.addEventListener(MixiVoiceParserEvent.PARSED, parsedVoiceHandler);
            parser.handler = handler;
            try {
                while (pageUTFBytes.bytesAvailable > 0) {
                    var fragment:ByteArray = new ByteArray();
                    var len:uint = (pageUTFBytes.bytesAvailable > 512)
                        ? 512 : pageUTFBytes.bytesAvailable;
                    pageUTFBytes.readBytes(fragment, 0, len);
                    parser.pushBytes(fragment);
                }
            } catch (e:*) {
                dispatchEvent(new MixiVoiceErrorEvent(
                    MixiVoiceErrorEvent.ERROR, e.message));
            }

            _isRetrieving = false;
            dispatchEvent(new MixiVoiceEvent(MixiVoiceEvent.COMPLETE));
        }

        private function foundPostKeyHandler(e:MixiPostKeyEvent):void
        {
            dispatchEvent(new MixiPostKeyEvent(MixiPostKeyEvent.FOUND, e.postKey));
        }

        private function parsedVoiceHandler(e:MixiVoiceParserEvent):void
        {
            dispatchEvent(new MixiVoiceEvent(
                MixiVoiceEvent.RETRIEVED, e.voice));
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            dispose();
            dispatchEvent(e);
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            dispose();
            dispatchEvent(e);
        }
    }
}

