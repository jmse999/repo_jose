import { encryptWithPublicKey, decryptWithPrivateKey } from "eth-crypto";
import { ec } from "elliptic";


/**
 Alice quiere enviar un mensaje secreto a Bob.
 
 1 - Bob generará una llave pública y privada. Guarda su llave privada. Comparte su llave pública con todos, incluida Alice.
 2 - Alice encripta el mensaje secreto utilizando la llave pública de Bob. Este mensaje cifrado se envía a través de Internet y un nadie es capaz de verlo.
 3- Bob recibirá el mensaje encriptado. Sin embargo, él será el único en descifrar el mensaje utilizando su llave privada que solo él conoce. 
 */

// 1 - Bob generará una llave pública y privada. Guarda su llave privada. Comparte su llave pública con todos, incluida Alice.
const curve = new ec("secp256k1");
const bobKeyPair = curve.genKeyPair();

async function encryptDecrypt() {
    const message = "Hola Bob, este es un mensaje secreto";

    // 2 - Alice encripta el mensaje secreto utilizando la llave pública de Bob. 
    // Este mensaje cifrado se envía a través de Internet y un nadie es capaz de verlo.
    const encryptedMessage = await encryptWithPublicKey(
        bobKeyPair.getPublic("hex"),
        message
    );

    console.log("Mensaje ecryptado", encryptedMessage);

    // Esto lo hace Bob
    // 3- Bob recibirá el mensaje encriptado. Sin embargo, él será el único en descifrar
    // el mensaje utilizando su llave privada que solo él conoce. 
    const decryptedMessage = await decryptWithPrivateKey(
        bobKeyPair.getPrivate("hex"),
        encryptedMessage
    );

    console.log(decryptedMessage);
}

encryptDecrypt();
