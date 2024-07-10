import React from 'react';
import './index.scss';

const App = () => (
  <>
    <div data-collapse="medium" data-animation="default" data-duration="400" data-easing="ease" data-easing2="ease"
        role="banner" className="navigation-bar w-nav">
      <div className="container-4 w-container"><a href="/" aria-current="page"
              className="brand-link w-nav-brand w--current"><img
                  src="/Icon.png"
                  loading="lazy" width="47" alt="" className="image" />
            <h1 className="brand-text">Homevestor</h1>
          </a>
          <nav role="navigation" className="navigation-menu w-nav-menu"><a href="/" aria-current="page"
                  className="navigation-link w-nav-link w--current">Sign in</a></nav>
          <div className="hamburger-button w-nav-button">
              <div className="w-icon-nav-menu"></div>
          </div>
      </div>
    </div>
    <div className="hero-section centered">
      <div data-w-id="e464d218-f801-55d1-1f50-7da00b5bfb8f" className="container w-container">
        <div className="w-layout-hflex flex-block">
            <h1 data-ix="fade-in-bottom-page-loads" className="interest-fee">0%</h1>
            <h1 data-ix="fade-in-bottom-page-loads" className="hero-heading">Decentralized Interest Free Mortgages.</h1>
        </div>
        <div data-ix="fade-in-bottom-page-loads" className="div-block"><a href="#"
                className="hollow-button all-caps">swap</a></div>
      </div>
    </div>
    <section>
      <div className="w-layout-blockcontainer container-3 w-container">
        <div className="div-block-2">
            <h2 className="heading">What is Homevestor?</h2>
            <p className="paragraph-2">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse varius enim
                in eros elementum tristique. Duis cursus, mi quis viverra ornare, eros dolor interdum nulla, ut
                commodo diam libero vitae erat. Aenean faucibus nibh et justo cursus id rutrum lorem imperdiet. Nunc
                ut sem vitae risus tristique posuere.</p>
        </div>
      </div>
    </section>
    <div className="hero-section">
      <div data-w-id="46337e64-666d-e1fe-d1ef-31271e61eab4" className="container-copy w-container">
        <div className="w-layout-hflex flex-block-2">
          <h1 data-ix="fade-in-bottom-page-loads" className="hero-heading-copy">What are HGB/LNFTs?</h1>
          <p className="paragraph">Discover the Pinnacle of Property Ownership with Our Extensive Portfolio,
              Exceptional Service, and Expertise in Navigating the Dynamic Real Estate Landscape</p>
        </div>
      </div>
    </div>
    <div className="section accent">
      <div className="w-container">
        <div className="section-title-group">
          <h2 className="section-heading centered white">Staking Mech</h2>
          <div className="section-subheading center off-white">Discover the Pinnacle of Property Ownership with Our
              Extensive Portfolio, Exceptional Service, and Expertise in Navigating the Dynamic Real Estate
              Landscape</div>
        </div>
        <div><a href="#" className="hollow-button all-caps">swap</a></div>
      </div>
    </div>
    <div className="footer">
      <div className="w-container">
        <div className="w-row">
          <div className="spc w-col w-col-4">
            <h5 className="heading-2"></h5>
            <p className="paragraph-3"></p>
          </div>
          <div className="spc w-col w-col-4">
            <h5>useful links</h5><a href="#" className="footer-link">Phasellus gravida semper nisi</a><a href="#"
                className="footer-link">Suspendisse nisl elit</a><a href="#" className="footer-link">Dellentesque
                habitant morbi</a><a href="#" className="footer-link">Etiam sollicitudin ipsum</a>
          </div>
          <div className="w-col w-col-4">
            <h5>social</h5>
            <div className="footer-link-wrapper w-clearfix"><img
                    src="/twitter.svg"
                    width="20" alt="" className="info-icon" /><a href="#" className="footer-link with-icon">Twitter</a>
            </div>
            <div className="footer-link-wrapper w-clearfix"><img
                    src="/facebook.svg"
                    width="20" alt="" className="info-icon" /><a href="#" className="footer-link with-icon">Facebook</a>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div className="footer center">
      <div className="w-container">
        <div className="footer-text"><a href="/">www.homevestor.org</a></div>
      </div>
    </div>
  </>
);

export default App;
