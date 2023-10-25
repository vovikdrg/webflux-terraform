module.exports.handler = async (event) => {
    console.log('Event: ', event);
    let responseMessage = 'Hello, World!';
    await new Promise((resolve, reject) => {
        setTimeout(() => resolve("hello"), 2000)
    });
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            message: responseMessage,
            count: Math.floor(Math.random() * 50)
        }),
    }
}