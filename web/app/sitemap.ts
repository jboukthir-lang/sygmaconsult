import { MetadataRoute } from 'next'

export default function sitemap(): MetadataRoute.Sitemap {
    const baseUrl = 'https://sygmaconsult.com' // Replace with actual domain

    // Static routes
    const routes = [
        '',
        '/services',
        '/about',
        '/contact',
        '/book',
        '/insights',
        '/careers',
        '/legal',
        '/privacy',
        '/terms',
    ].map((route) => ({
        url: `${baseUrl}${route}`,
        lastModified: new Date(),
        changeFrequency: 'monthly' as const,
        priority: route === '' ? 1 : 0.8,
    }))

    // Dynamic service routes
    const services = [
        'strategic',
        'financial-legal',
        'visa',
        'corporate',
        'hr-training',
        'compliance',
        'digital',
        'real-estate',
        // 'international' // Merged/Redirected
    ].map((slug) => ({
        url: `${baseUrl}/services/${slug}`,
        lastModified: new Date(),
        changeFrequency: 'weekly' as const,
        priority: 0.9,
    }))

    return [...routes, ...services]
}
