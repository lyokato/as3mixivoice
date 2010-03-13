package suite
{
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;

    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.webservices.mixi.events.MixiVoiceEvent;
    import org.coderepos.webservices.mixi.events.MixiPostKeyEvent;
    import org.coderepos.webservices.mixi.events.MixiVoiceErrorEvent;
    import org.coderepos.webservices.mixi.voice.MixiVoiceRetrievalTransaction;
    import org.coderepos.webservices.mixi.voice.MixiVoicePostTransaction;

    public class VoiceTest extends TestCase
    {
        private var _voices:Array;
        private var _postKey:String;

        private var cookie:String;
        private var postKey:String;

        public function VoiceTest(meth:String)
        {
            super(meth);
            cookie = "";
            postKey = "";
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new VoiceTest("testRetrieve"));
            ts.addTest(new VoiceTest("testPost"));
            return ts;
        }

        public function testPost():void
        {
            var txn:MixiVoicePostTransaction = new MixiVoicePostTransaction(cookie, postKey);
            txn.addEventListener(MixiVoiceEvent.POSTED, addAsync(postedHandler, 3600));
            //txn.addEventListener(MixiVoiceErrorEvent.ERROR, errorHandler);
            //txn.addEventListener(IOErrorEvent.IO_ERROR, dummyIO);
            //txn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dummySEC);
            txn.start("ほげ");
        }

        public function postedHandler(e:MixiVoiceEvent):void
        {
            assertEquals('posted', '');
        }

        public function testRetrieve():void
        {
            _voices = [];
            _postKey = null;
            var txn:MixiVoiceRetrievalTransaction = new MixiVoiceRetrievalTransaction(cookie);
            txn.addEventListener(MixiVoiceEvent.RETRIEVED, retrievedHandler);
            txn.addEventListener(MixiPostKeyEvent.FOUND, postKeyHandler);
            //txn.addEventListener(MixiVoiceEvent.COMPLETE, addAsync(completeHandler, 3600));
            txn.addEventListener(MixiVoiceErrorEvent.ERROR, addAsync(errorHandler, 3600));
            //txn.addEventListener(IOErrorEvent.IO_ERROR, dummyIO);
            //txn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dummySEC);
            txn.start();
        }

        private function postKeyHandler(e:MixiPostKeyEvent):void
        {
            _postKey = e.postKey;
        }

        private function retrievedHandler(e:MixiVoiceEvent):void
        {
            _voices.push(e.voice);
        }

        private function completeHandler(e:MixiVoiceEvent):void
        {
            //assertEquals(_postKey, "aaa");
            //assertEquals(_voices[0].toString(), '');
            assertEquals(_voices.length, 3);
        }

        private function errorHandler(e:MixiVoiceErrorEvent):void
        {
            assertEquals(e.message, '');
        }

        private function dummyIO(e:SecurityErrorEvent):void
        {

        }
        private function dummySEC(e:SecurityErrorEvent):void
        {

        }
    }
}

