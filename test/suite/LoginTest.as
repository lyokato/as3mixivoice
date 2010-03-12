package suite
{
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;

    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import org.coderepos.webservices.mixi.login.MixiLoginTransaction;
    import org.coderepos.webservices.mixi.events.MixiLoginEvent;

    public class LoginTest extends TestCase
    {
        public function LoginTest(meth:String)
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new LoginTest("testInvalidLogin"));
            ts.addTest(new LoginTest("testLogin"));
            return ts;
        }

        public function testInvalidLogin():void
        {
            var email:String = "";
            var pass:String  = "";
            var loginTxn:MixiLoginTransaction = new MixiLoginTransaction();
            //loginTxn.addEventListener(MixiLoginEvent.COMPLETE, addAsync(loginHandler, 3600));
            loginTxn.addEventListener(MixiLoginEvent.ERROR, addAsync(errorHandler, 3600));
            //loginTxn.addEventListener(IOErrorEvent.IO_ERROR, dummyIO);
            //loginTxn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dummySEC);
            loginTxn.login(email, pass);
        }

        public function testLogin():void
        {
            var email:String = "";
            var pass:String  = "";
            var loginTxn:MixiLoginTransaction = new MixiLoginTransaction();
            loginTxn.addEventListener(MixiLoginEvent.COMPLETE, addAsync(loginHandler, 3600));
            //loginTxn.addEventListener(MixiLoginEvent.ERROR, addAsync(errorHandler, 3600));
            //loginTxn.addEventListener(IOErrorEvent.IO_ERROR, dummyIO);
            //loginTxn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dummySEC);
            loginTxn.login(email, pass);
        }

        private function errorHandler(e:MixiLoginEvent):void
        {
            assertEquals('', '');
        }


        private function loginHandler(e:MixiLoginEvent):void
        {
            assertEquals(e.cookie, '');
        }

        private function dummyIO(e:SecurityErrorEvent):void
        {

        }
        private function dummySEC(e:SecurityErrorEvent):void
        {

        }
    }
}

