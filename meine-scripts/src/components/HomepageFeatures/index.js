import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: 'Netpurple Ecosystem',
    icon: '💜',
    description: (
      <>
        <span style={{color: '#000000'}}>
          Comprehensive documentation and tools for the Netpurple ecosystem, 
          centralizing our knowledge and utilities.
        </span>
      </>
    ),
  },
  {
    title: 'Flipper Zero Integration',
    icon: '🐬',
    description: (
      <>
        Control and automate Windows environments using Flipper Zero. 
        Explore guides for Windows Enrolment, Wi-Fi Login, and more.
      </>
    ),
  },
  {
    title: 'Windows Utilities',
    icon: '🪟',
    description: (
      <>
        Maintain and verify your system with our Windows tools, 
        including the CheckPC utility for system health checks.
      </>
    ),
  },
];

function Feature({icon, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <div style={{fontSize: '5rem'}}>{icon}</div>
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
