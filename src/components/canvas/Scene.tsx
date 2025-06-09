
import projectState from './Ribbon r3f Project.theatre-project-state.json'
import { PerformanceMonitor, Preload, Stats, useProgress, useTexture } from '@react-three/drei'
import { Canvas } from '@react-three/fiber'
import { getProject, types } from '@theatre/core'
import { SheetProvider } from '@theatre/r3f'
// import extension from '@theatre/r3f/dist/extension'
// import studio from '@theatre/studio'
import { Leva } from 'leva'
import { Suspense, useEffect, useRef, useState } from 'react'
import * as THREE from 'three'
import Experience from './Experience'
// import Interface from './Interface'
import { useIsClient, useWindowSize } from '@uidotdev/usehooks'
import { useCarouselImages } from './constants'


const isProd = true

// if (!isProd) {
// studio.initialize()
// studio.extend(extension)
// studio.ui.hide()
// }


export const project = getProject(
	'Ribbon r3f Project',
	isProd
		? {
			state: projectState,
		}
		: undefined
)

export const ribbonSheet = project.sheet('Ribbon r3f Sheet')

function PreloadAssets() {
	const { imageUrls } = useCarouselImages()
	useTexture([...imageUrls])
	useTexture('https://flowing-ribbon.vercel.app/linen/Plain_Grey_Texture_col.jpg')
	useTexture('https://flowing-ribbon.vercel.app/linen/Plain_Grey_Texture_nrm.jpg')

	return <></>
}


export default function Scene() {
	// const setIntroCompleted = useAnimationStore((state) => state.setIntroCompleted)
	// const [start, setStart] = useState(false)
	// const isClient = useIsClient()
	// const GPUTier = useDetectGPU()
		const {width} = useWindowSize()
		const [isMobile, setIsMobile] = useState(true)
		const [animationStart, setAnimationStart] = useState(false)
	const { total } = useProgress()
	const [readyToStart, setReadyToStart] = useState(false)
	const [dpr, setDpr] = useState(2)

		useEffect(() => {
			if(!width) return
			// console.log('width', width)
			if (width < 768) {
				setIsMobile(true)
			} else {
				setIsMobile(false)
			}
		},[width])



	useEffect(() => {
		// console.log(total)
		if (total === 14) {
			const timer = setTimeout(() => {
				setReadyToStart(true)
			}, 2000)

			return () => clearTimeout(timer)
		}
	}, [total])
	

	const isClient = useIsClient()


	const progressRef = useRef(0)
	const timeRef = useRef(0)

	useEffect(() => {
		let animationId: number
		const animate = () => {
			timeRef.current += 0.01
			animationId = requestAnimationFrame(animate)
		}

		animate()

		return () => {
			if (animationId) {
				cancelAnimationFrame(animationId)
			}
		}
	}, [timeRef])
	
  

	const animationProgress = ribbonSheet?.object('progress',
		{
			x: types.number(0,
				{
					range: [-1, 1.5],
					nudgeMultiplier: 0.0001
				}
			) 
		},
		{ reconfigure: true }
	)
	animationProgress?.onValuesChange((value) => {
		progressRef.current = value.x
	}
	)

	const time = ribbonSheet?.object('time',
		{
			t: types.number(0,
				{
					range: [0, 100],
					nudgeMultiplier: 0.0001,
				}
			)
		},
		{ reconfigure: true }
	)
	time?.onValuesChange((value) => {
		timeRef.current = value.t
	})

	useEffect(() => {
		ribbonSheet.sequence.position = 0
		if(readyToStart){
			// Delay the animation by 2.5 seconds
			const animationTimer = setTimeout(() => {
				project.ready.then(() => {
					setAnimationStart(true)
					ribbonSheet.sequence.position = 0
					ribbonSheet.sequence
						.play({
							range: [0, 6 + 22 / 30],
						})
				})
			}, 2500)
			
			// Cleanup function to clear the timeout if component unmounts
			return () => clearTimeout(animationTimer)
		}
	}, [readyToStart])


	if (!isClient) return null

	return (
		<>
			<Leva hidden />
			<Canvas
				shadows
				gl={{
					antialias: false,
					preserveDrawingBuffer: true,
					powerPreference: 'high-performance',
					toneMappingExposure: 2,
					precision: "highp"
				}}
				onCreated={({ gl }) => {
					gl.clearDepth()
					gl.toneMapping = THREE.NoToneMapping
					gl.getContext().getExtension('OES_texture_float')
				}}
				dpr={dpr}
				style={{
					zIndex: 50,
					position: 'fixed',
					top: 0,
					left: 0,
					width: '100vw',
					height: '100vh',
					pointerEvents: 'auto',
					touchAction: 'none',
					backgroundColor: 'transparent'
				}}
			>
				<Stats />

				<Suspense fallback={null}>
					<SheetProvider sheet={ribbonSheet}>
						{/* <Bvh> */}
							<group visible={animationStart} dispose={null}>
								{readyToStart && 
									<>
										<Experience
											progressRef={progressRef}
											timeRef={timeRef}
											isMobile={isMobile}
										/>
										<PerformanceMonitor
											bounds={(refreshrate) => {
												console.log(refreshrate)
										return refreshrate > 90 ? [90, 120] : [50, 70]
											}}
											onIncline={() => {
												setDpr(3)
												console.log('incline')
											}} 
											onDecline={() =>{ 
												setDpr(1)
												console.log('declined')
											}} 
											flipflops={3} 
											onFallback={(api) =>{ 
												console.log('api',api)
												if(dpr === 3 && api.fps < 60 ) setDpr(2)
												if(dpr === 2 && api.fps < 60 ) setDpr(1)
												console.log(dpr)
												console.log('fallback')
											}} 
										/>
									</>
								}
								<PreloadAssets />
							</group>
						{/* </Bvh> */}
						{/* <RibbonText 
								progressRef={progressRef}
								timeRef={timeRef}
							/> */}
						<Preload all />
					</SheetProvider>
				</Suspense>
			</Canvas>
			{/* <Interface /> */}
		</>
	)
}
