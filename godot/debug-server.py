
# if ./export doesn't exist, throw an error
import os
if not os.path.exists('./export'):
    print('Error: ./export does not exist. Please export the project from within godot.')
    exit()




from http.server import HTTPServer, SimpleHTTPRequestHandler, test as test_orig

import sys

def test (*args):
    os.chdir('./export')
    test_orig(*args, port=int(sys.argv[1]) if len(sys.argv) > 1 else 8000)



class CORSRequestHandler (SimpleHTTPRequestHandler):
    def end_headers (self):
        self.send_header('Access-Control-Allow-Origin', '*')

        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')

        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')

        SimpleHTTPRequestHandler.end_headers(self)



if __name__ == '__main__':
    test(CORSRequestHandler, HTTPServer)