import React from 'react';
import './index.scss';

const App = () => (
  <>
    <div data-collapse="medium" data-animation="default" data-duration="400" data-easing="ease" data-easing2="ease"
        role="banner" className="navigation-bar w-nav">
      <div className="w-container navbar-w">
        <a href="/" aria-current="page" className="brand-link w-nav-brand w--current">
          <img src="/logo-white.svg" loading="lazy" width="360" alt="" className="image" />
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
            <h2 className="heading">What is HomeVestors?</h2>
            <p className="paragraph-2">HomeVestors DAO democratizes property investment, making it accessible and rewarding for everyone. Historically, real estate has been a reliable and lucrative investment, but significant barriers like high upfront costs have limited participation to the wealthy. HomeVestors DAO breaks down these barriers through property fractionalization, innovative tokenomics, and an asset-backed stable coin.  HomeVestors DAO leverages cutting-edge technology to make property investment simple, accessible, and highly profitable for everyone.</p>
            <p className="paragraph-2">Join us in transforming the real estate investment landscape.</p>
        </div>
      </div>
    </section>
    <div className="hero-section">
      <div data-w-id="46337e64-666d-e1fe-d1ef-31271e61eab4" className="container-copy w-container">
        <div className="w-layout-hflex flex-block-2">
          <h1 data-ix="fade-in-bottom-page-loads" className="hero-heading-copy">What are HGB/LNFTs?</h1>

          <p className="paragraph">
          <pre>1LNFT : 1000HGB</pre>
          With HomeVestors DAO, you can invest in property through Loan Non-fungible Tokens (LNFTs), which represent £1000 of equity within a property, without granting ownership of future capital appreciation.</p>
        </div>
      </div>
    </div>
    <div className="section accent">
      <div className="w-container">
        <div className="section-title-group">
          <h2 className="section-heading centered white">The Stable Mechanism</h2>
          <div className="section-subheading center off-white">These arbitrage activities ensure that HGB remains pegged to the pound (GBP), maintaining its stability and value. Through this mechanism, HomeVestors DAO leverages market forces to provide consistent and reliable opportunities for investors.</div>
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
            <h5>useful links</h5>
              {/* <a href="#" className="footer-link">Phasellus gravida semper nisi</a>
              <a href="#" className="footer-link">Suspendisse nisl elit</a>
              <a href="#" className="footer-link">Dellentesque
              habitant morbi</a>
              <a href="#" className="footer-link">Etiam sollicitudin ipsum</a> */}
          </div>
          <div className="w-col w-col-4">
            <h5>social</h5>
            {/* <div className="footer-link-wrapper w-clearfix"><img
                    src="/twitter.svg"
                    width="20" alt="" className="info-icon" /><a href="#" className="footer-link with-icon">Twitter</a>
            </div>
            <div className="footer-link-wrapper w-clearfix"><img
                    src="/facebook.svg"
                    width="20" alt="" className="info-icon" /><a href="#" className="footer-link with-icon">Facebook</a>
            </div> */}
          </div>
        </div>
      </div>
    </div>
    <div className="footer center">
      <div className="w-container">
        <div className="footer-text"><a href="/">www.homevestorsDAO.com</a></div>
      </div>
    </div>
  </>
);

export default App;
