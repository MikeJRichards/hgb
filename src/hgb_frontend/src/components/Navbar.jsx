import React from 'react'
import WalletConnect from './WalletConnect';
// import { HamburgerIcon } from '@chakra-ui/icons';

const Navbar = ({authClient, setAuthClient, principalId, setPrincipalId, setPlayer1Cards, setPlayer2Cards}) => {
  const [isOpen, setIsOpen] = React.useState(false);

  const toggleDrawer = () => {
    setIsOpen(!isOpen);
  };

  return (
    <div data-collapse="medium" data-animation="default" data-duration="400" data-easing="ease" data-easing2="ease"
        role="banner" className="navigation-bar w-nav">
    <div className="w-container navbar-w">
      <a href="/" aria-current="page" className="brand-link w-nav-brand w--current">
        <img src="/logo-white.svg" loading="lazy" width="360" alt="" className="image" />
        </a>
        <nav role="navigation" className="navigation-menu w-nav-menu">
          <a href="/" aria-current="page"
                className="navigation-link w-nav-link w--current"><WalletConnect/></a></nav>
        <div className="hamburger-button w-nav-button">
          <div className="w-icon-nav-menu"></div>
        </div>
      </div>
    </div>
  );
}

export default Navbar
