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

    import org.coderepos.webservices.mixi.events.MixiVoiceEvent;
    import org.coderepos.webservices.mixi.events.MixiVoiceParserEvent;
    import org.coderepos.webservices.mixi.events.MixiVoiceErrorEvent;

    public class MixiVoicePostTransaction extends EventDispatcher
    {
        private var _cookie:String;
        private var _postKey:String;
        private var _loader:URLLoader;
        private var _isRetrieving:Boolean;

        public function MixiVoicePostTransaction(cookie:String, postKey:String)
        {
            _cookie       = cookie;
            _postKey      = postKey;
            _isRetrieving = false;
        }

        public function get isRetrieving():Boolean
        {
            return _isRetrieving;
        }

        private function formatPostTime(d:Date):String
        {
            return String(d.fullYear)
             + String(d.month + 1)
             + String(d.date)
             + String(d.hours)
             + String(d.minutes)
             + String(d.seconds);
        }

        public function start(message:String, parentMemberID:uint=0,
            parentPostTime:Date=null):void
        {
            if (_isRetrieving)
                throw new Error("Alerady retrieving");

            var messageBytes:ByteArray = Jcode.to_euc(message);
            if (messageBytes.length > 150)
                throw new ArgumentError("message length is over 150.");

            _isRetrieving = true;
            var req:URLRequest = new URLRequest(MixiVoiceEndpoint.POST);
            req.requestHeaders.push(new URLRequestHeader("Cookie", _cookie));
            req.manageCookies   = false;
            req.followRedirects = false;
            req.method = URLRequestMethod.POST;

            var params:ByteArray = new ByteArray();
            params.writeUTFBytes("post_key=");
            params.writeUTFBytes(_postKey);
            if (parentMemberID != 0 && parentPostTime != null) {
                params.writeUTFBytes("&parent_member_id=");
                params.writeUTFBytes(String(parentMemberID));
                params.writeUTFBytes("&parent_post_time=");
                params.writeUTFBytes(formatPostTime(parentPostTime));
            }
            params.writeUTFBytes("&redirect=recent_echo");
            params.writeUTFBytes("&body=");
            params.writeUTFBytes(Jcode.encodeURIComponentBytes(messageBytes));
            params.position = 0;
            req.data = params;

            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE, postCompleteHandler);
            _loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, postStatusHandler);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _loader.dataFormat = URLLoaderDataFormat.BINARY;
            _loader.load(req);
        }

        private function dispose():void
        {
            _isRetrieving = false;
        }

        private function postStatusHandler(e:HTTPStatusEvent):void
        {
            if (e.status == 302) {
                _isRetrieving = false;
                dispatchEvent(new MixiVoiceEvent(MixiVoiceEvent.POSTED));
            } else {
                dispatchEvent(new MixiVoiceErrorEvent(
                    MixiVoiceErrorEvent.ERROR, "failed to post."));
            }
        }

        private function postCompleteHandler(e:Event):void
        {
            _isRetrieving = false;
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

