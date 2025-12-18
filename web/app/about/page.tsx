import Header from "@/components/Header";
import OfficeMap from "@/components/OfficeMap";
import { Award, Globe, Users } from "lucide-react";

export default function AboutPage() {
    return (
        <main className="min-h-screen bg-white">
            <Header />

            {/* Hero */}
            <section className="bg-[#001F3F] py-24 text-center text-white">
                <div className="container px-4 mx-auto">
                    <h1 className="text-4xl md:text-6xl font-serif font-bold mb-6">About Sygma Consult</h1>
                    <p className="text-xl text-blue-200 max-w-2xl mx-auto">
                        Bridging the gap between European standards and African opportunities since 2015.
                    </p>
                </div>
            </section>

            {/* Stats */}
            <section className="py-12 bg-[#F8F9FA] border-b border-gray-100">
                <div className="container px-4 mx-auto grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
                    <div>
                        <div className="text-4xl font-bold text-[#D4AF37] mb-2">10+</div>
                        <div className="text-sm font-semibold text-[#001F3F] uppercase tracking-wide">Years Experience</div>
                    </div>
                    <div>
                        <div className="text-4xl font-bold text-[#D4AF37] mb-2">500+</div>
                        <div className="text-sm font-semibold text-[#001F3F] uppercase tracking-wide">Clients Served</div>
                    </div>
                    <div>
                        <div className="text-4xl font-bold text-[#D4AF37] mb-2">2</div>
                        <div className="text-sm font-semibold text-[#001F3F] uppercase tracking-wide">Main Offices</div>
                    </div>
                    <div>
                        <div className="text-4xl font-bold text-[#D4AF37] mb-2">50M€+</div>
                        <div className="text-sm font-semibold text-[#001F3F] uppercase tracking-wide">Value Created</div>
                    </div>
                </div>
            </section>

            {/* Story */}
            <section className="py-20">
                <div className="container px-4 mx-auto max-w-4xl space-y-8">
                    <h2 className="text-3xl font-bold text-[#001F3F] font-serif">Our Story</h2>
                    <p className="text-lg text-gray-600 leading-relaxed">
                        Sygma Consult was born from a vision to create a seamless business corridor between France and Tunisia. Recognizing the complexities that entrepreneurs face when operating across these two vibrant economies, we established a firm grounded in deep local expertise and international standards.
                    </p>
                    <p className="text-lg text-gray-600 leading-relaxed">
                        Today, we are proud to be the trusted partner for multinational corporations, SMEs, and visionary startups. Our dual presence in Paris and Tunis allows us to offer real-time, on-the-ground support that other firms cannot match.
                    </p>

                    <div className="grid md:grid-cols-3 gap-8 pt-12">
                        <div className="text-center p-6 rounded-xl bg-gray-50">
                            <Globe className="h-10 w-10 text-[#001F3F] mx-auto mb-4" />
                            <h3 className="font-bold text-lg mb-2">Global Vision</h3>
                            <p className="text-sm text-gray-500">Thinking beyond borders to unlock international potential.</p>
                        </div>
                        <div className="text-center p-6 rounded-xl bg-gray-50">
                            <Users className="h-10 w-10 text-[#001F3F] mx-auto mb-4" />
                            <h3 className="font-bold text-lg mb-2">Client Centric</h3>
                            <p className="text-sm text-gray-500">Your success is the only metric that matters to us.</p>
                        </div>
                        <div className="text-center p-6 rounded-xl bg-gray-50">
                            <Award className="h-10 w-10 text-[#001F3F] mx-auto mb-4" />
                            <h3 className="font-bold text-lg mb-2">Excellence</h3>
                            <p className="text-sm text-gray-500">Delivering premium quality in every consultation.</p>
                        </div>
                    </div>
                </div>
            </section>

            {/* Office Locations Map */}
            <section className="py-20 bg-[#F8F9FA]">
                <div className="container px-4 mx-auto">
                    <div className="max-w-6xl mx-auto">
                        <div className="text-center mb-12">
                            <h2 className="text-3xl font-bold text-[#001F3F] font-serif mb-4">Our Offices</h2>
                            <p className="text-lg text-gray-600 max-w-2xl mx-auto">
                                With strategic locations in Paris and Tunis, we provide comprehensive support across Europe and North Africa.
                            </p>
                        </div>
                        <OfficeMap />
                    </div>
                </div>
            </section>

        </main>
    );
}
