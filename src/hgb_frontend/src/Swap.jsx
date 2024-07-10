import React from 'react';

const Swap = () => (
  <>
    <div className='container mx-auto'>

      <div className='flex flex-row justify-around'>
        <div className='flex flex-col'>
          <h2 className='font-bold text-4xl'>SWAP</h2>
          <div className='border border-slate-950 p-16'>
            <label className="form-control w-full max-w-xs">
              <div className="label">
                <span className="label-text">From: <span className='font-semibold'>ICP Mainnet</span></span>
                <span className="label-text-alt"><pre>Select Token</pre></span>
              </div>
              <input type="text" placeholder="0.00" className="input input-bordered input-lg w-full max-w-xs" />
              <div className="label">
                <span className="label-text-alt">Balance: 0.00 <a href='#'>MAX</a></span>
              </div>
            </label>

            <label className="form-control w-full max-w-xs">
              <div className="label">
                <span className="label-text">To: --</span>
                <span className="label-text-alt"><pre>Select Token</pre></span>
              </div>
              <input type="text" placeholder="0.00" className="input input-bordered input-lg w-full max-w-xs" />
            </label>
          </div>
          </div>


        <ul className="timeline timeline-snap-icon timeline-vertical">
          <li>
            <div className="timeline-end h-24 font-bold text-xl">Starting swap</div>
              <div className="timeline-middle">
                <div className="badge badge-info">1</div>
              </div>
            <hr />
          </li>
          <li>
            <hr />
            <div className="timeline-end h-24 font-bold text-xl">Crossing bridge</div>
            <div className="timeline-middle">
              <div className="badge">2</div>
            </div>
            <hr />
          </li>
          <li>
            <hr />
            <div className="timeline-end h-24 font-bold text-xl">Approving transfer</div>
            <div className="timeline-middle">
              <div className="badge">3</div>
            </div>
            <hr />
          </li>
          <li>
              <hr />
              <div className="timeline-end h-24 font-bold text-xl">Complete</div>
              <div className="timeline-middle">
                <div className="badge">4</div>
              </div>
          </li>
        </ul>
      </div>
    </div>
  </>
);

export default Swap;
