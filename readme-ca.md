# nginx Certs

https://dgu2000.medium.com/working-with-self-signed-certificates-in-chrome-walkthrough-edition-a238486e6858

- Step 1: Becoming your own CA

cd ../data/nginx/certs

openssl genrsa -des3 -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 730 -out rootCA.pem
openssl x509 -in rootCA.pem -text -noout

- Step 2: Creating a certificate request

openssl genrsa -out tls.key 2048
openssl req -new -key tls.key -out tls.csr

Create openssl.cnf:

	# Extensions to add to a certificate request
	basicConstraints       = CA:FALSE
	authorityKeyIdentifier = keyid:always, issuer:always
	keyUsage               = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
	subjectAltName         = @alt_names
	[ alt_names ]
	DNS.1 = mydomain.local
	DNS.2 = *.mydomain.local

- Step 3: Signing the certificate request using CA

openssl x509 -req \
    -in tls.csr \
    -CA rootCA.pem \
    -CAkey rootCA.key \
    -CAcreateserial \
    -out tls.crt \
    -days 730 \
    -sha256 \
    -extfile openssl.cnf

openssl verify -CAfile rootCA.pem -verify_hostname mydomain.local tls.crt

- Step 4: Adding CA as trusted to Chrome

Open Chrome settings, select Security > Manage Certificates.
Click the Authorities tab, then click the Import… button. This opens the Certificate Import Wizard. Click Next to get to the File to Import screen.
Click Browse… and select rootCA.pem then click Next.
Check Trust this certificate for identifying websites then click OK to finish the process.
