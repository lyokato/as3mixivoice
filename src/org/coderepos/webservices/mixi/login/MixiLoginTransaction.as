/*
Copyright (c) Lyo Kato (lyo.kato _at_ gmail.com)

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package org.coderepos.webservices.mixi.login
{
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

    import org.coderepos.webservices.mixi.events.MixiLoginEvent;

    public class MixiLoginTransaction extends EventDispatcher
    {
        private static const LOGIN_URI:String = "http://mixi.jp/login.pl";

        private var _loader:URLLoader;
        private var _cookie:String;
        private var _isFetching:Boolean;

        public function MixiLoginTransaction()
        {
            _cookie     = "";
            _isFetching = false;
        }

        public function login(email:String, pass:String):void
        {
            if (_isFetching)
                throw new Error("now fetching.");

            _isFetching = true;
            var req:URLRequest = new URLRequest(LOGIN_URI);
            req.method = URLRequestMethod.POST;
            var params:URLVariables = new URLVariables();
            params.email    = email;
            params.password = pass;
            params.next_url = '/home.pl';
            req.data = params;
            // for AIR only
            req.followRedirects = false;
            req.manageCookies   = false;
            _loader = new URLLoader();
            _loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, loginStatusHandler);
            _loader.addEventListener(Event.COMPLETE, loginCompleteHandler);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _loader.load(req);
        }

        private function loginStatusHandler(e:HTTPStatusEvent):void
        {
            if (e.status != 200)
                return;

            // for AIR only
            var headers:Array = e.responseHeaders;
            _cookie = "";
            for each(var header:URLRequestHeader in headers) {
                if (header.name.toLowerCase() == "set-cookie") {
                    var value:String = header.value;
                    var parts:Array = value.split(/\,/);
                    for each (var part:String in parts) {
                        _cookie += part.substring(0, part.indexOf(";"));
                        _cookie += ";";
                    }
                }
            }
        }

        private function loginCompleteHandler(e:Event):void
        {
            _isFetching = false;
            if (_cookie != null && _cookie.length > 0) {
                dispatchEvent(new MixiLoginEvent(MixiLoginEvent.COMPLETE, _cookie));
            } else {
                dispatchEvent(new MixiLoginEvent(MixiLoginEvent.ERROR));
            }
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            _isFetching = false;
            dispatchEvent(e);
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            _isFetching = false;
            dispatchEvent(e);
        }
    }
}

