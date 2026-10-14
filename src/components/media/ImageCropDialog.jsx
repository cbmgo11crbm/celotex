import { useCallback, useEffect, useRef, useState } from 'react';
import Cropper from 'react-easy-crop';

function getImageElement(imageSrc) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => resolve(image);
    image.onerror = reject;
    image.src = imageSrc;
  });
}

async function getCroppedImageBlob(imageSrc, croppedAreaPixels, mimeType = 'image/jpeg') {
  const image = await getImageElement(imageSrc);

  const canvas = document.createElement('canvas');
  canvas.width = croppedAreaPixels.width;
  canvas.height = croppedAreaPixels.height;
  const ctx = canvas.getContext('2d');

  ctx.drawImage(
    image,
    croppedAreaPixels.x,
    croppedAreaPixels.y,
    croppedAreaPixels.width,
    croppedAreaPixels.height,
    0,
    0,
    croppedAreaPixels.width,
    croppedAreaPixels.height,
  );

  return new Promise((resolve, reject) => {
    canvas.toBlob(
      (blob) => {
        if (!blob) {
          reject(new Error('Falha ao gerar imagem recortada.'));
          return;
        }
        resolve(blob);
      },
      mimeType,
      0.92,
    );
  });
}

async function blobToImageUrl(blob) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

async function compressImageBlob(blob, options = {}) {
  const {
    maxWidth = 1200,
    maxHeight = 1200,
    maxSizeKB = 1024,
    mimeType = 'image/jpeg',
    minQuality = 0.6,
  } = options;

  const image = await getImageElement(await blobToImageUrl(blob));

  let width = image.width;
  let height = image.height;

  if (width > maxWidth || height > maxHeight) {
    const scale = Math.min(maxWidth / width, maxHeight / height, 1);
    width = Math.round(width * scale);
    height = Math.round(height * scale);
  }

  const canvas = document.createElement('canvas');
  canvas.width = width;
  canvas.height = height;
  const ctx = canvas.getContext('2d');
  ctx.drawImage(image, 0, 0, width, height);

  const maxBytes = maxSizeKB * 1024;
  let quality = 0.92;

  while (quality >= minQuality) {
    const compressed = await new Promise((resolve, reject) => {
      canvas.toBlob(
        (b) => {
          if (!b) {
            reject(new Error('Falha ao comprimir imagem.'));
            return;
          }
          resolve(b);
        },
        mimeType,
        quality,
      );
    });

    if (compressed.size <= maxBytes) {
      return compressed;
    }

    quality = Math.max(minQuality, quality - 0.05);
  }

  return new Promise((resolve, reject) => {
    canvas.toBlob(
      (b) => {
        if (!b) {
          reject(new Error('Falha ao comprimir imagem.'));
          return;
        }
        resolve(b);
      },
      mimeType,
      minQuality,
    );
  });
}

function imageUrlToBlob(imageUrl, mimeType = 'image/png') {
  return fetch(imageUrl)
    .then((res) => res.blob())
    .then((blob) => new Blob([blob], { type: mimeType }));
}

export default function ImageCropDialog({
  open,
  imageSrc,
  aspect = 16 / 9,
  onCancel,
  onConfirm,
  allowBackgroundRemoval = false,
}) {
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState(null);
  const [step, setStep] = useState('crop');
  const [croppedBlob, setCroppedBlob] = useState(null);
  const [croppedPreview, setCroppedPreview] = useState(null);
  const [processedPreview, setProcessedPreview] = useState(null);
  const [removeBg, setRemoveBg] = useState(true);
  const [useWhiteBg, setUseWhiteBg] = useState(true);
  const [isProcessing, setIsProcessing] = useState(false);
  const [processError, setProcessError] = useState(null);
  const revokedUrls = useRef([]);

  const handleCropComplete = useCallback((_, areaPixels) => {
    setCroppedAreaPixels(areaPixels);
  }, []);

  useEffect(() => {
    if (!open) {
      setStep('crop');
      setCroppedBlob(null);
      setCroppedPreview(null);
      setProcessedPreview(null);
      setRemoveBg(true);
      setUseWhiteBg(true);
      setIsProcessing(false);
      setProcessError(null);
      revokedUrls.current.forEach((url) => URL.revokeObjectURL(url));
      revokedUrls.current = [];
    }
  }, [open]);

  async function handleCropNext() {
    if (!croppedAreaPixels) {
      onCancel?.();
      return;
    }

    try {
      const blob = await getCroppedImageBlob(imageSrc, croppedAreaPixels);
      setCroppedBlob(blob);
      const url = URL.createObjectURL(blob);
      revokedUrls.current.push(url);
      setCroppedPreview(url);

      if (allowBackgroundRemoval) {
        setStep('process');
      } else {
        onConfirm?.(blob);
      }
    } catch (error) {
      console.error(error);
      onCancel?.();
    }
  }

  async function handleProcess() {
    if (!croppedBlob) return;

    setIsProcessing(true);
    setProcessError(null);
    setProcessedPreview(null);

    try {
      let blob = croppedBlob;

      if (removeBg) {
        const { removeBackground } = await import('@imgly/background-removal');
        blob = await removeBackground(blob, {
          output: {
            format: 'image/png',
            quality: 0.92,
          },
          progress: () => {},
        });
      }

      if (useWhiteBg) {
        const whiteCanvas = document.createElement('canvas');
        const img = await getImageElement(await blobToImageUrl(blob));
        whiteCanvas.width = img.width;
        whiteCanvas.height = img.height;
        const ctx = whiteCanvas.getContext('2d');
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, whiteCanvas.width, whiteCanvas.height);
        ctx.drawImage(img, 0, 0);

        const whiteBlob = await new Promise((resolve, reject) => {
          whiteCanvas.toBlob(
            (b) => {
              if (!b) {
                reject(new Error('Falha ao gerar imagem com fundo branco.'));
                return;
              }
              resolve(b);
            },
            'image/png',
            0.92,
          );
        });
        blob = whiteBlob;
      }

      const url = URL.createObjectURL(blob);
      revokedUrls.current.push(url);
      setProcessedPreview(url);
    } catch (error) {
      console.error(error);
      setProcessError('Não foi possível processar a imagem. Tente novamente.');
    } finally {
      setIsProcessing(false);
    }
  }

  async function handleConfirm() {
    try {
      const url = processedPreview ?? croppedPreview;
      if (!url) {
        onCancel?.();
        return;
      }
      const finalBlob = await imageUrlToBlob(url, 'image/png');
      const compressedBlob = await compressImageBlob(finalBlob, {
        maxWidth: 1200,
        maxHeight: 1200,
        maxSizeKB: 1024,
        mimeType: 'image/jpeg',
        minQuality: 0.6,
      });
      onConfirm?.(compressedBlob);
    } catch (error) {
      console.error(error);
      onCancel?.();
    }
  }

  if (!open || !imageSrc) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-3">
      <div className="w-full max-w-2xl rounded-lg border bg-background p-4 text-sm shadow-lg">
        <div className="mb-3 flex items-center justify-between">
          <div>
            <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
              Ajustar foto
            </div>
            <div className="text-xs text-muted-foreground">
              {step === 'crop'
                ? 'Arraste e use o zoom para enquadrar a foto.'
                : 'Ajuste o fundo da foto antes de confirmar.'}
            </div>
          </div>
          <button
            type="button"
            className="text-xs text-muted-foreground hover:text-foreground"
            onClick={onCancel}
          >
            Fechar
          </button>
        </div>

        {step === 'crop' && (
          <>
            <div className="relative h-64 w-full overflow-hidden rounded-md bg-muted">
              <Cropper
                image={imageSrc}
                crop={crop}
                zoom={zoom}
                aspect={aspect}
                onCropChange={setCrop}
                onZoomChange={setZoom}
                onCropComplete={handleCropComplete}
                restrictPosition
              />
            </div>

            <div className="mt-3 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className="text-[11px] text-muted-foreground">Zoom</span>
                <input
                  type="range"
                  min={1}
                  max={3}
                  step={0.1}
                  value={zoom}
                  onChange={(e) => setZoom(Number(e.target.value))}
                />
              </div>
              <div className="flex gap-2">
                <button
                  type="button"
                  className="rounded-md border border-input bg-background px-3 py-1 text-xs text-foreground hover:bg-accent"
                  onClick={onCancel}
                >
                  Cancelar
                </button>
                <button
                  type="button"
                  className="rounded-md bg-primary px-3 py-1 text-xs font-medium text-primary-foreground hover:bg-primary/90"
                  onClick={handleCropNext}
                >
                  {allowBackgroundRemoval ? 'Próximo' : 'Aplicar recorte'}
                </button>
              </div>
            </div>
          </>
        )}

        {step === 'process' && (
          <>
            <div className="relative flex h-64 w-full items-center justify-center overflow-hidden rounded-md bg-muted">
              {processedPreview ? (
                <img
                  src={processedPreview}
                  alt="Prévia processada"
                  className="max-h-full max-w-full object-contain"
                />
              ) : croppedPreview ? (
                <img
                  src={croppedPreview}
                  alt="Prévia recortada"
                  className="max-h-full max-w-full object-contain"
                />
              ) : null}
            </div>

            <div className="mt-3 space-y-2">
              <div className="flex flex-wrap items-center gap-3 text-xs">
                <label className="flex items-center gap-1.5">
                  <input
                    type="checkbox"
                    className="h-3 w-3 rounded border"
                    checked={removeBg}
                    onChange={(e) => setRemoveBg(e.target.checked)}
                  />
                  <span>Remover fundo</span>
                </label>
                <label className="flex items-center gap-1.5">
                  <input
                    type="checkbox"
                    className="h-3 w-3 rounded border"
                    checked={useWhiteBg}
                    onChange={(e) => setUseWhiteBg(e.target.checked)}
                  />
                  <span>Fundo branco</span>
                </label>
              </div>

              {processError && (
                <div className="rounded-md border border-red-200 bg-red-50 px-2 py-1 text-[11px] text-red-700">
                  {processError}
                </div>
              )}

              <div className="flex items-center justify-between">
                <button
                  type="button"
                  className="text-xs text-muted-foreground hover:text-foreground"
                  onClick={() => setStep('crop')}
                  disabled={isProcessing}
                >
                  Voltar ao recorte
                </button>
                <div className="flex gap-2">
                  <button
                    type="button"
                    className="rounded-md border border-input bg-background px-3 py-1 text-xs text-foreground hover:bg-accent disabled:opacity-60"
                    onClick={handleProcess}
                    disabled={isProcessing}
                  >
                    {isProcessing ? 'Processando...' : 'Processar'}
                  </button>
                  <button
                    type="button"
                    className="rounded-md bg-primary px-3 py-1 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-60"
                    onClick={handleConfirm}
                    disabled={isProcessing || !processedPreview}
                  >
                    Usar esta foto
                  </button>
                </div>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
