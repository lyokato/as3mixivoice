package org.coderepos.webservices.mixi.voice
{
    import flash.events.EventDispatcher;

    import org.coderepos.xml.sax.IXMLSAXHandler;
    import org.coderepos.xml.XMLAttributes;
    import org.coderepos.webservices.mixi.events.MixiVoiceParserEvent;
    import org.coderepos.webservices.mixi.events.MixiPostKeyEvent;
    import org.coderepos.webservices.mixi.exceptions.MixiProtocolError;

    public class MixiVoiceSAXHandler extends EventDispatcher implements IXMLSAXHandler
    {
        private var _buffer:MixiVoiceBuffer;

        public function MixiVoiceSAXHandler()
        {
        }

        public function startDocument():void
        {
            // just for interface
        }

        public function endDocument():void
        {
            // just for interface
        }

        public function startElement(ns:String, localName:String,
            attrs:XMLAttributes, depth:uint):void
        {
            if (localName == "input") {
                var inputType:String = attrs.getValue("type");
                var inputName:String = attrs.getValue("name");
                if (   inputType != null && inputType == "hidden"
                    && inputName != null && inputName == "post_key" ) {
                    var postKey:String = attrs.getValue("value");
                    dispatchEvent(new MixiPostKeyEvent(MixiPostKeyEvent.FOUND, postKey));
                }
            }

            if (localName != "div")
                return;

            var classValue:String = attrs.getValue("class");
            if (classValue == null)
                return;

            switch (classValue) {
                case MixiVoiceElementClassType.MEMBER_ID:
                    _buffer = new MixiVoiceBuffer();
                    _buffer.startCapturing(
                        MixiVoiceElementClassType.MEMBER_ID);
                    break;
                case MixiVoiceElementClassType.POST_TIME:
                    if (_buffer == null)
                        throw new MixiProtocolError("Invalid voice format");
                    _buffer.startCapturing(
                        MixiVoiceElementClassType.POST_TIME);
                    break;
                case MixiVoiceElementClassType.NICKNAME:
                    if (_buffer == null)
                        throw new MixiProtocolError("Invalid voice format");
                    _buffer.startCapturing(
                        MixiVoiceElementClassType.NICKNAME);
                    break;
                case MixiVoiceElementClassType.BODY:
                    if (_buffer == null)
                        throw new MixiProtocolError("Invalid voice format");
                    _buffer.startCapturing(
                        MixiVoiceElementClassType.BODY);
                    break;
                case MixiVoiceElementClassType.OFFICIAL_POST:
                    if (_buffer == null)
                        throw new MixiProtocolError("Invalid voice format");
                    _buffer.startCapturing(
                        MixiVoiceElementClassType.OFFICIAL_POST);
                    break;
            }
        }

        public function endElement(ns:String, localName:String, depth:uint):void
        {
            if (_buffer != null && _buffer.isCapturing) {
                _buffer.finishCapturing();
                if (_buffer.hasEnough) {
                    var voice:MixiVoice = _buffer.buildVoice();
                    _buffer = null;
                    dispatchEvent(new MixiVoiceParserEvent(
                        MixiVoiceParserEvent.PARSED, voice));
                }
            }
        }

        public function cdata(s:String):void
        {
            // just for interface
        }

        public function characters(s:String):void
        {
            if (_buffer != null && _buffer.isCapturing)
                _buffer.capture(s);
        }

        public function comment(s:String):void
        {
            // just for interface
        }
    }
}

