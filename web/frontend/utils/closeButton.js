export function attachCloseButtonListener(shop_domain) {
    const checkForCloseButton = setInterval(() => {
        const closeButton = document.getElementById('closeButton');
        if (closeButton) {
            clearInterval(checkForCloseButton);
            addCloseButtonListener(closeButton, shop_domain);
        }
    }, 100); // Check every 100 milliseconds
}

function addCloseButtonListener(closeButton, shop_domain) {
    closeButton.addEventListener('click', async () => {
        try {
            const response = await fetch(`/api/hotwire/close?shop_domain=${encodeURIComponent(shop_domain)}`);
            if (!response.ok) {
                console.error('closeButton Error:', response.status);
            }
        } catch (error) {
            console.error('closeButton Fetch error:', error);
        }
    });
}
